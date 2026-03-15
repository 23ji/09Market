//
//  HomeReactor.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore
import Domain
import Shared_DI
import Shared_ReactiveX

final class HomeReactor: Reactor, FactoryModule {

    struct Dependency {
        let fetchPostsListUseCase: FetchPostsListUseCase
        let fetchTop10PostsUseCase: FetchTop10PostsUseCase
    }

    enum Action {
        case fetchPostList
        case loadNextPage
        case selectCategory(GroupBuyingCategory?)
    }

    enum Mutation {
        case setLoading(Bool)
        case setFetchCompleted(Page<Post>)
        case setSelectedCategory(GroupBuyingCategory?)
        case setError(AppError?)
    }

    struct State {
        var sections: [HomeSectionModel] = []
        var posts: [Post] = []
        var selectedCategory: GroupBuyingCategory?
        var searchKeyword: String?
        var currentPage: Int = 1
        var hasNextPage: Bool = true
        var isLoading: Bool = false
        @Pulse var error: AppError?
    }

    let initialState: State = State()
    private let dependency: Dependency
    private let pageSize = 10

    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPostList:
            return fetchPosts(page: self.currentState.currentPage)

        case .loadNextPage:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            guard self.currentState.hasNextPage else {
                return .empty()
            }

            return fetchPosts(page: self.currentState.currentPage + 1)
            
        case .selectCategory(let category):
            guard category != self.currentState.selectedCategory else {
                return .empty()
            }
            
            return .concat([
                .just(.setSelectedCategory(category)),
                fetchPosts(page: 1)
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setFetchCompleted(let page):
            if page.page == 1 {
                newState.posts = page.data
            } else {
                newState.posts += page.data
            }
            
            newState.currentPage = page.page
            newState.hasNextPage = newState.posts.count < page.total
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts
            )
        
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts
            )

        case .setError(let error):
            newState.error = error
        }
        return newState
    }
    
    private func fetchPosts(page: Int) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.task {
                try await self.dependency.fetchPostsListUseCase.execute(
                    page: page,
                    limit: self.pageSize,
                    search: self.currentState.searchKeyword,
                    category: self.currentState.selectedCategory,
                    dateFrom: nil,
                    dateTo: nil
                )
            }
            .map { Mutation.setFetchCompleted($0) }
            .catch { .just(.setError($0 as? AppError)) },
            .just(.setLoading(false))
        ])
    }
}


// MARK: - Build Sections

extension HomeReactor {
    private func buildSections(
        selectedCategory: GroupBuyingCategory?,
        posts: [Post]
    ) -> [HomeSectionModel] {
        var categories: [HomeSectionItem] = [
            .category(nil, selectedCategory == nil),
        ]
        categories += GroupBuyingCategory.allCases.map { category in
            .category(category, category == selectedCategory)
        }

        let postItems: [HomeSectionItem] = posts.map { .post($0) }

        return [
            .category(items: categories),
            .top10Banner(items: [.top10Banner]),
            .postList(items: postItems),
        ]
    }
}
