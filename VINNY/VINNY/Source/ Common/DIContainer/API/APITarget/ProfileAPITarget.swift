//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum ProfileAPITarget {
    
    case getProfile
    case getWrittenPosts
    case getSavedShops
    //case getSavedPosts
    //case updateProfile(request: ProfileUpdateRequestDTO)
    //case updateProfileImage(image: Data)
}

extension ProfileAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.profileURL)!
    }
    
    var path: String {
        switch self {
        case .getProfile:
            return "/me"
        case .getWrittenPosts:
            return "/posts"
        case .getSavedShops:
            return "/liked-shops"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
        case .getWrittenPosts:
            return .get
        case .getSavedShops:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getProfile:
            return .requestPlain

        case .getWrittenPosts:
            return .requestPlain

        case .getSavedShops:
            return .requestPlain

        }
    }
    
    var sampleData: Data {
        switch self {
        case .getProfile:
            let json = """
                        {
                        "success": true,
                        "message": "프로필 정보를 조회했습니다.",
                        "status": 200,
                        "data": {
                        "userId": 1,
                        "nickname": "조휴일",
                        "profileImage": "https://cdn.example.com/profile1.jpg",
                        "comment": "캐릿공방장",
                        "postCount": 5,
                        "likedShopCount": 9,
                        "savedCount": 3
                        },
                        "timestamp": "2025-07-29T12:00:00Z"
                        }

                        """
                        return Data(json.utf8)
        case .getWrittenPosts:
            let json = """
                        {       
                        "success": true,
                        "message": "내가 작성한 게시글 목록 조회 성공",
                        "status": 200,
                        "data": [
                        {
                        "postId": 1,
                        "title": "오늘의 OOTD",
                        "content": "빈티지 자켓 코디 추천!",
                        "imageUrls": [
                        "https://cdn.example.com/post1-img1.jpg",
                        "https://cdn.example.com/post1-img2.jpg"
                        ],
                        "createdAt": "2025-07-27T13:00:00Z"
                        }
                        ],
                        "timestamp": "2025-07-29T12:00:00Z"
                        }
                        
                        """
                        return Data(json.utf8)

        case .getSavedShops:
            let json = """
                        {
                        "success": true,
                        "message": "찜한 상점 목록 조회 성공",
                        "status": 200,
                        "data": [
                        {
                        "shopId": 101,
                        "shopName": "산 이름",
                        "region": "서울",
                        "categories": ["카테고리1", "카테고리2"],
                        "thumbnailUrl": "https://cdn.example.com/shops/101.jpg",
                        "isLiked": true
                        }
                        ],
                        "timestamp": "2025-07-29T12:00:00Z"
                        }

                        
                        """
                    return Data(json.utf8)
            
        }
    }
}


