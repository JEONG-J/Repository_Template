//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum MypageAPITarget {
    
    case getProfile //마이프로필 정보 조회
    case getWrittenPosts //작성한 게시글 썸네일 목록 조회
    case getSavedShops //찜한 샵 목록 조회
    case getSavedPosts // 저장한 게시글 첫 이미지 리스트 조회
    //case updateProfile(request: ProfileUpdateRequestDTO)
    //case updateProfileImage(image: Data)
}

extension MypageAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.mypageURL)!
    }
    
    var path: String {
        switch self {
        case .getProfile:
            return "profile"
        case .getWrittenPosts:
            return "posts"
        case .getSavedShops:
            return "liked-shops"
        case .getSavedPosts:
            return "saved-posts/images"
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
        case .getSavedPosts:
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
            
        case .getSavedPosts:
            return .requestPlain

        }
    }
}


