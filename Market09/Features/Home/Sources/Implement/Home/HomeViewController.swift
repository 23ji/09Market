//
//  HomeViewController.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import DesignSystem
import Domain
import Shared_DI
import Shared_ReactiveX
import Shared_UI

import Kingfisher

final class HomeViewController: UIViewController, FactoryModule {
    
    // MARK: - Init
    
    struct Dependency {
        let reactor: HomeReactor
    }
    
    var disposeBag = DisposeBag()
    
    required init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        defer { self.reactor = dependency.reactor }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "브랜드, 상품 검색"
        $0.searchBarStyle = .minimal
    }
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSectionModel>(
        configureCell: { _, collectionView, indexPath, item in
            switch item {
            case .category(let category, let isSelected):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CategoryCell", for: indexPath
                ) as? CategoryChipCell else { return UICollectionViewCell() }

                cell.configure(
                    dependency: .init(),
                    payload: .init(category: category, isSelected: isSelected)
                )

                return cell

            case .top10Banner:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "BannerCell", for: indexPath
                )
                cell.contentView.backgroundColor = .systemOrange
                    .withAlphaComponent(0.2)
                return cell

            case .post:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PostCell", for: indexPath
                )
                cell.contentView.backgroundColor = .systemGray6
                return cell
            }
        }
    )

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: HomeCollectionViewLayout.create()
        )
        cv.backgroundColor = .systemBackground
        cv.register(CategoryChipCell.self, forCellWithReuseIdentifier: "CategoryCell")
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "BannerCell")
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PostCell")
        return cv
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.collectionView)

        self.searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension HomeViewController: View {
    func bind(reactor: HomeReactor) {

        // MARK: - Action

        Observable.just(Reactor.Action.viewDidLoad)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .filter { $0.section == 0 }
            .withLatestFrom(reactor.state.map(\.sections)) { indexPath, sections in
                guard case .category(let category, _) = sections[0].items[indexPath.item] else {
                    return nil as GroupBuyingCategory?
                }
                return category
            }
            .bind(to: reactor.action.mapObserver { .selectCategory($0) })
            .disposed(by: self.disposeBag)

        // MARK: - State

        reactor.state.map(\.sections)
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}
