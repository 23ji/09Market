//
//  HomeCollectionViewLayout.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

enum HomeCollectionViewLayout {
    static func create() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return createCategorySection()
                
            case 1:
                return createBannerSection()
                
            default:
                return createPostListSection()
            }
        }
    }
    
    // MARK: - Section 0: 카테고리 칩

    private static func createCategorySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(80),
            heightDimension: .absolute(36)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        return section
    }


    // MARK: - Section 1: TOP 10 배너

    private static func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 16, trailing: 16
        )
        return section
    }


    // MARK: - Section 2: 공동구매 리스트

    private static func createPostListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 16, trailing: 16
        )
        return section
    }
}
