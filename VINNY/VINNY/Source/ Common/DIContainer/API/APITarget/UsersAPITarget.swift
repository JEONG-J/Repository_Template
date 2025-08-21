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
    case getYourSavedShop(userId: Int)
    case getYourProfile(userId: Int)
    case getYourPost(userId: Int)
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
        case .getYourSavedShop(let userId):
            return "\(userId)/shops/favorites"
        case .getYourProfile(let userId):
            return "\(userId)/profile"
        case .getYourPost(let userId):
            return "\(userId)/posts"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getYourSavedShop:
            return .get
        case .getYourProfile:
            return .get
        case .getYourPost:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getYourSavedShop:
            return .requestPlain
        case .getYourProfile:
            return .requestPlain
        case .getYourPost:
            return .requestPlain
        }
    }
    
    
}


