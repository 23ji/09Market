//
//  HomeReactor.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

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
        case viewDidLoad
        case selectCategory(GroupBuyingCategory?)
    }

    enum Mutation {
        case setSections([HomeSectionModel])
    }

    struct State {
        var sections: [HomeSectionModel] = []
    }

    let initialState: State = State()
    private let dependency: Dependency

    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let categories: [HomeSectionItem] = GroupBuyingCategory.allCases.enumerated()
                .map { index, category in
                    .category(category, index == 0)
                }

            let sections: [HomeSectionModel] = [
                .category(items: categories),
                .top10Banner(items: []),
                .postList(items: []),
            ]

            return .just(.setSections(sections))

        case .selectCategory:
            return .empty()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSections(let sections):
            newState.sections = sections
        }
        return newState
    }
}
