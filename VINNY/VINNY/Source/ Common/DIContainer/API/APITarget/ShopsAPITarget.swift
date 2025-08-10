//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum ShopsAPITarget {
    
    //코스 상세정보 API
    case getShopReview(shopId: Int)//가게 후기 목록 조회
    case deleteShopReview(shopId: Int, reviewId: Int)//가게 후기 삭제
    case getshopDetail(shopId: Int)//가게 상세 조회
    
}

extension ShopsAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.shopURL)!
    }
    
    var path: String {
        switch self {
        case .getShopReview(let shopId):
            return "\(shopId)/reviews"
        case .deleteShopReview(let shopId, let reviewId):
            return "\(shopId)/reviews/\(reviewId)"
        case .getshopDetail(let shopId):
            return "\(shopId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShopReview, .getshopDetail:
            return .get
        case .deleteShopReview:
            return .delete

        }
    }
    
    var task: Task {
        switch self {
            case .getShopReview:
             return .requestPlain
        case .deleteShopReview:
            return .requestPlain
        case .getshopDetail:
            return .requestPlain

        }
    }
    
}


