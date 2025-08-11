//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum UsersAPITarget {
    
    //코스 상세정보 API
    case getSavedShop
    
}

extension UsersAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.userURL)!
    }
    
    var path: String {
        switch self {
        case .getSavedShop:
            return "/me/shops/favorite"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSavedShop:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getSavedShop:
            return .requestPlain
        }
    }
    
    
}


