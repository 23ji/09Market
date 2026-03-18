//
//  Strings.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

public enum Strings {
    public enum Common {
        public static let confirm = "확인"
        public static let cancel = "취소"
        public static let retry = "재시도"
    }

    public enum Tab {
        public static let home = "홈"
        public static let temp = "임시"
        public static let profile = "프로필"
    }

    public enum Home {
        public static let searchPlaceholder = "브랜드, 상품 검색"
        public static let loginRequired = "로그인이 필요합니다.\n로그인 화면으로 이동할까요?"
        public static let goToLink = "공구 링크로 이동"
        public static let priceUndecided = "가격 미정"
        public static let categoryAll = "전체"
        public static let top10Banner = "이번 주 핫딜 TOP 10"
        public static let statusUpcoming = "오픈예정"
        public static let statusOngoing = "진행중"
        public static let statusClosingSoon = "마감임박"
        public static let statusClosed = "마감"

        public static func likesCount(_ count: Int) -> String {
            return "\(count)명이 좋아합니다"
        }

        public static func price(_ formatted: String) -> String {
            return "\(formatted)원"
        }
    }

    public enum Profile {
        public static let login = "로그인하기"
        public static let logout = "로그아웃"
        public static let deleteAccount = "회원탈퇴"
        public static let logoutConfirm = "로그아웃 하시겠어요?"
        public static let defaultNickname = "사용자"
    }

    public enum Auth {
        public static let googleLogin = "구글 로그인"
        public static let appleLogin = "애플 로그인"
        public static let splash = "스플래시"
    }
}
