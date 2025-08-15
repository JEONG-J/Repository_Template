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
    case updateProfile(dto: MyPageNicknameDTO)// 닉네임 한줄소개 수정
    case updateProfileImage(image: Data)//프사 수정
    case updateBackground(image: Data)// 배사 수정
}

extension MypageAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        var h: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "ko-KR,ko;q=0.9"
        ]

        // AccessToken이 있으면 Authorization 헤더 추가
        if let token = KeychainHelper.shared.get(forKey: "accessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }

        // Content-Type 조건부 설정
        switch self {
        case .updateProfileImage, .updateBackground:
            h["Content-Type"] = "multipart/form-data"
        default:
            h["Content-Type"] = "application/json"
        }

        return h
    }
    
    var baseURL: URL{
        return URL(string: API.mypageURL)!
    }
    
    var path: String {
        switch self {
        case .getProfile:
            return "/profile"
        case .getWrittenPosts:
            return "/posts"
        case .getSavedShops:
            return "/liked-shops"
        case .getSavedPosts:
            return "/saved-posts/images"
        case .updateProfile:
            return ""
        case .updateProfileImage:
            return "/profile-image"
        case .updateBackground:
            return "/background-image"

        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getProfile, .getWrittenPosts, .getSavedShops, .getSavedPosts:
            return .get
        case .updateProfile, .updateProfileImage, .updateBackground:
            return .patch
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
            
        case .updateProfile(let dto):
            return .requestJSONEncodable(dto)

        case .updateProfileImage(let image):
            let multipart = MultipartFormData(
                provider: .data(image),
                name: "file",
                fileName: "image.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([multipart])
            
        case .updateBackground(let image):
            let multipart = MultipartFormData(
                provider: .data(image),
                name: "file",
                fileName: "image.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([multipart])
        }
    }
}


