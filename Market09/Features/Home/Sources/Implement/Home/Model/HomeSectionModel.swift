//
//  HomeSectionModel.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import Domain

import RxDataSources

// MARK: - Section Item

enum HomeSectionItem {
    case category(GroupBuyingCategory, Bool)
    case top10Banner
    case post
}


// MARK: - Section Model

enum HomeSectionModel {
    case category(items: [HomeSectionItem])
    case top10Banner(items: [HomeSectionItem])
    case postList(items: [HomeSectionItem])
}

extension HomeSectionModel: SectionModelType {
    typealias Item = HomeSectionItem
    
    var items: [HomeSectionItem] {
        switch self {
        case .category(let items):
            return items
            
        case .top10Banner(let items):
            return items
            
        case .postList(let items):
            return items
        }
    }
    
    init(original: HomeSectionModel, items: [HomeSectionItem]) {
        switch original {
        case .category:
            self = .category(items: items)
            
        case .top10Banner:
            self = .top10Banner(items: items)
            
        case .postList:
            self = .postList(items: items)
        }
    }
}
