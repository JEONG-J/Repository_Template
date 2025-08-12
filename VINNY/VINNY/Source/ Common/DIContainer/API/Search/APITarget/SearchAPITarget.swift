//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum SearchAPITarget {
    
    //코스 상세정보 API
    case getSearchShop
    case getSearchPost
    
}

extension SearchAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "*/*",
            "Accept-Language": "ko-KR,ko;q=0.9"
        ]
    }
    
    var baseURL: URL {
        return URL(string:"https://app.vinnydesign.net/")! // 명세서 URL
    }
    
    var path: String {
        switch self {
            
        case .getSearchShop:
            return "api/search/shop/search"
        case .getSearchPost:
            return "api/search/posts/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSearchShop:
            return .post
            
        case .getSearchPost:
            return .post
        }
    }
    
    var task: Task {
        switch self {
            
            
        case .getSearchShop:
            return .requestPlain
            
        case .getSearchPost:
            return .requestPlain
            
        }
    }
}


