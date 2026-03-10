import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { createSupabaseClient, requireAuth, optionalAuth } from "../_shared/auth.ts";
import { requireFields, parseIntParam } from "../_shared/validation.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get("action");

    switch (true) {
      case req.method === "GET" && action === "list":
        return await handleList(req, url);
      case req.method === "GET" && action === "top10":
        return await handleTop10(req, url);
      case req.method === "POST" && action === "create":
        return await handleCreate(req);
      case req.method === "PUT" && action === "update":
        return await handleUpdate(req);
      case req.method === "DELETE" && action === "delete":
        return await handleDelete(req);
      default:
        return errorResponse("bad_request", "Unknown action or method", 400);
    }
  } catch (e) {
    if (e && typeof e === "object" && "status" in e) {
      return errorResponse(
        (e as Record<string, unknown>).error as string,
        (e as Record<string, unknown>).message as string,
        (e as Record<string, unknown>).status as number
      );
    }
    return errorResponse("internal_error", String(e), 500);
  }
});

// ─── GET /posts?action=list ───

async function handleList(req: Request, url: URL): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await optionalAuth(supabase);

  const page = parseIntParam(url, "page", 1);
  const limit = Math.min(parseIntParam(url, "limit", 20), 50);
  const search = url.searchParams.get("search");
  const category = url.searchParams.get("category");
  const dateFrom = url.searchParams.get("date_from");
  const dateTo = url.searchParams.get("date_to");
  const offset = (page - 1) * limit;

  let query = supabase
    .from("posts")
    .select(
      "id, product_name, price, category, image_urls, group_buying_start, group_buying_end, group_buying_url, likes_count, posted_at, influencers(id, username, full_name, profile_pic_url, external_url)",
      { count: "exact" }
    )
    .not("group_buying_start", "is", null)
    .not("group_buying_end", "is", null);

  // 날짜 필터
  if (dateFrom && dateTo) {
    query = query
      .lte("group_buying_start", dateTo)
      .gte("group_buying_end", dateFrom);
  } else {
    const now = new Date().toISOString();
    query = query
      .lte("group_buying_start", now)
      .gte("group_buying_end", now);
  }

  // 카테고리 필터
  if (category) {
    query = query.eq("category", category);
  }

  // 검색
  if (search) {
    const { data: matchedInfluencers } = await supabase
      .from("influencers")
      .select("id")
      .or(`username.ilike.%${search}%,full_name.ilike.%${search}%`);

    const ids = (matchedInfluencers ?? []).map((i: { id: string }) => i.id);

    if (ids.length > 0) {
      query = query.or(
        `product_name.ilike.%${search}%,influencer_id.in.(${ids.join(",")})`
      );
    } else {
      query = query.ilike("product_name", `%${search}%`);
    }
  }

  // 정렬 + 페이지네이션
  query = query
    .order("group_buying_start", { ascending: false })
    .range(offset, offset + limit - 1);

  const { data, error, count } = await query;

  if (error) {
    return errorResponse("query_error", error.message, 500);
  }

  // is_liked 처리
  const posts = data ?? [];
  let likedSet: Set<string> = new Set();

  if (authUser && posts.length > 0) {
    const postIds = posts.map((p: { id: string }) => p.id);
    const { data: likes } = await supabase
      .from("likes")
      .select("post_id")
      .eq("user_id", authUser.id)
      .in("post_id", postIds);

    likedSet = new Set((likes ?? []).map((l: { post_id: string }) => l.post_id));
  }

  const result = posts.map((post: Record<string, unknown>) => ({
    ...post,
    influencer: post.influencers,
    influencers: undefined,
    is_liked: likedSet.has(post.id as string),
  }));

  return jsonResponse({ data: result, total: count, page }, 200);
}

// ─── GET /posts?action=top10 ───

async function handleTop10(req: Request, _url: URL): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await optionalAuth(supabase);

  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const { data, error } = await supabase
    .from("posts")
    .select(
      "id, product_name, price, category, image_urls, group_buying_start, group_buying_end, group_buying_url, likes_count, posted_at, influencers(id, username, full_name, profile_pic_url, external_url)"
    )
    .not("group_buying_start", "is", null)
    .not("group_buying_end", "is", null)
    .lte("group_buying_start", now.toISOString())
    .gte("group_buying_end", weekAgo)
    .order("likes_count", { ascending: false })
    .limit(10);

  if (error) {
    return errorResponse("query_error", error.message, 500);
  }

  const posts = data ?? [];
  let likedSet: Set<string> = new Set();

  if (authUser && posts.length > 0) {
    const postIds = posts.map((p: { id: string }) => p.id);
    const { data: likes } = await supabase
      .from("likes")
      .select("post_id")
      .eq("user_id", authUser.id)
      .in("post_id", postIds);

    likedSet = new Set((likes ?? []).map((l: { post_id: string }) => l.post_id));
  }

  const result = posts.map((post: Record<string, unknown>, index: number) => ({
    ...post,
    influencer: post.influencers,
    influencers: undefined,
    is_liked: likedSet.has(post.id as string),
    rank: index + 1,
  }));

  return jsonResponse(result, 200);
}

// ─── POST /posts?action=create ───

async function handleCreate(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  const authUser = await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, [
    "influencer_id",
    "product_name",
    "price",
    "category",
    "group_buying_start",
    "group_buying_end",
  ]);

  // 인플루언서 존재 확인
  const { data: influencer, error: infError } = await supabase
    .from("influencers")
    .select("id")
    .eq("id", body.influencer_id)
    .single();

  if (infError || !influencer) {
    return errorResponse("influencer_not_found", "Influencer not found", 404);
  }

  const { data, error } = await supabase
    .from("posts")
    .insert({
      id: crypto.randomUUID(),
      influencer_id: body.influencer_id,
      product_name: body.product_name,
      price: body.price,
      category: body.category,
      image_urls: body.image_urls ?? null,
      group_buying_start: body.group_buying_start,
      group_buying_end: body.group_buying_end,
      group_buying_url: body.group_buying_url ?? null,
      submitted_by: authUser.id,
      post_url: "",
      posted_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) {
    return errorResponse("insert_error", error.message, 500);
  }

  return jsonResponse(data, 201);
}

// ─── PUT /posts?action=update ───

async function handleUpdate(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, ["post_id"]);

  const updates: Record<string, unknown> = {};
  const allowedFields = [
    "product_name",
    "price",
    "category",
    "image_urls",
    "group_buying_start",
    "group_buying_end",
    "group_buying_url",
  ];

  for (const field of allowedFields) {
    if (body[field] !== undefined) {
      updates[field] = body[field];
    }
  }

  if (Object.keys(updates).length === 0) {
    return errorResponse("no_fields_to_update", "No fields to update", 400);
  }

  const { data, error } = await supabase
    .from("posts")
    .update(updates)
    .eq("id", body.post_id)
    .select()
    .single();

  if (error) {
    if (error.code === "PGRST116") {
      return errorResponse("not_found", "Post not found", 404);
    }
    return errorResponse("update_error", error.message, 500);
  }

  return jsonResponse(data, 200);
}

// ─── DELETE /posts?action=delete ───

async function handleDelete(req: Request): Response | Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createSupabaseClient(authHeader);
  await requireAuth(supabase);

  const body = await req.json();
  requireFields(body, ["post_id"]);

  await supabase
    .from("posts")
    .delete()
    .eq("id", body.post_id);

  return new Response(null, { status: 204, headers: corsHeaders });
}
