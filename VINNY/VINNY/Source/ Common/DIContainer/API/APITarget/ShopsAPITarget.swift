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
    case postShopReview(shopId: Int, dto: ReviewCreateDTO, images: [Data]) //가게 후기 작성
    case deleteShopReview(shopId: Int, reviewId: Int)//가게 후기 삭제
    case getshopDetail(shopId: Int)//가게 상세 조회
    
}

extension ShopsAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        var h: [String: String] = [:]
        if let token = KeychainHelper.shared.get(forKey: "accessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }
        return h.isEmpty ? nil : h
    }
    
    var baseURL: URL{
        return URL(string: API.shopURL)!
    }
    
    var path: String {
        switch self {
        case .getShopReview(let shopId), .postShopReview(let shopId, _, _):
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
        case .postShopReview:
            return .post
        case .deleteShopReview:
            return .delete

        }
    }
    
    var task: Task {
        switch self {
        case .getShopReview, .deleteShopReview, .getshopDetail:
            return .requestPlain

        case .postShopReview(_, let dto, let images):
            // dto를 JSON 문자열 파트로
            let jsonData = try! JSONEncoder().encode(dto)
            var parts: [MultipartFormData] = [
                MultipartFormData(provider: .data(jsonData),
                                  name: "dto",
                                  fileName: nil,
                                  mimeType: "application/json")
            ]
            for (i, data) in images.enumerated() {
                parts.append(
                    MultipartFormData(provider: .data(data),
                                      name: "images",      // 스펙이 배열이므로 같은 name 반복
                                      fileName: "image\(i+1).jpg",
                                      mimeType: "image/jpeg")
                )
            }
            return .uploadMultipart(parts)
        }
    }
}


