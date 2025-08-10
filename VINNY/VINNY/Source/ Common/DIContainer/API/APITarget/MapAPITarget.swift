//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum MapAPITarget {
    
    //코스 상세정보 API
    case getAllShop
    case getSavedShopOnMap
    case getShopOnMap(shopId: Int)
}

extension MapAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.mapURL)!
    }
    
    var path: String {
        switch self {
        case .getAllShop:
            return "/all"
        case .getSavedShopOnMap:
            return "/favorite"
        case .getShopOnMap(let shopId):
            return "/shops/\(shopId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllShop:
            return .get
        case .getSavedShopOnMap:
            return .get
        case .getShopOnMap:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAllShop:
            return .requestPlain
        case .getSavedShopOnMap:
            return .requestPlain
        case .getShopOnMap:
            return .requestPlain
        
        }
    }
    
}


