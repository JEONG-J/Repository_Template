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
//    case getShopOnMap(shopId: Int)
}

extension MapAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        var h: [String: String] = [
            "Accept": "application/json"
        ]
        // getAllShop엔 토큰 금지
        switch self {
        case .getAllShop:
            break
        default:
            if let token = KeychainHelper.shared.get(forKey: "accessToken"), !token.isEmpty {
                h["Authorization"] = "Bearer \(token)"
            }
        }
        return h
    }
    
    var baseURL: URL{
        return URL(string: API.mapURL)!
    }
    
    var path: String {
        switch self {
        case .getAllShop:
            return "shops/all"
        case .getSavedShopOnMap:
            return "shops/favorite"
//        case .getShopOnMap(let shopId):
//            return "/shops/\(shopId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllShop:
            return .get
        case .getSavedShopOnMap:
            return .get
//        case .getShopOnMap:
//            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAllShop:
            return .requestPlain
        case .getSavedShopOnMap:
            return .requestPlain
//        case .getShopOnMap:
//            return .requestPlain
        
        }
    }
    
}


