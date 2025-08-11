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
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.searchURL)!
    }
    
    var path: String {
        switch self {
        case .getSearchShop:
            return "/shops/style"
            
        case .getSearchPost:
            return "/posts/style"
            
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
//        case .getCourseDetail(let request):
//            let parameters: [String: Any] = [
//                "courseId" : request.courseId
//            ]
//            // GET인 경우(parameter)
//            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
            // POST인 경우(response body)
            // return .requestJSONEncodable(request)
        case .getSearchShop:
            return .requestPlain

        case .getSearchPost:
            return .requestPlain

        }
    }
}


