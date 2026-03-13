//
//  CategoryChipCell.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import Domain
import Shared_DI
import Shared_UI

final class CategoryChipCell: UICollectionViewCell, ConfiguratorModule {

    struct Dependency {}

    struct Payload {
        let category: GroupBuyingCategory
        let isSelected: Bool
    }


    // MARK: - UI

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textAlignment = .center
    }


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Configure

extension CategoryChipCell {
    func configure(dependency: Dependency, payload: Payload) {
        self.titleLabel.text = payload.category.rawValue

        if payload.isSelected {
            self.contentView.backgroundColor = .systemOrange
            self.titleLabel.textColor = .white
        } else {
            self.contentView.backgroundColor = .white
            self.titleLabel.textColor = .gray
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
}


// MARK: - Layout

extension CategoryChipCell {
    private func setupLayout() {
        self.contentView.layer.cornerRadius = 18
        self.contentView.clipsToBounds = true

        self.contentView.flex.justifyContent(.center)
            .alignItems(.center)
            .paddingHorizontal(16)
            .define { flex in
                flex.addItem(self.titleLabel)
            }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.flex.layout(mode: .adjustWidth)
    }
}


// MARK: - Reuse

extension CategoryChipCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.borderColor = nil
    }
}
