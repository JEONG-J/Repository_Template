//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

enum PostsAPITarget {
    
    case getAllPost //전체 피드 조회
    case getDetailPost(postId: Int)// 게시글 상세 조회
    case deletePostLike(postId: Int)//좋아요 삭제
    case deletePostBookmark(postId: Int)//북마크 삭제
    case deletePost(postId: Int)//게시글 삭제
}

extension PostsAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL{
        return URL(string: API.postURL)!
    }
    
    var path: String {
        switch self {
        case .getAllPost:
            return ""
        case .getDetailPost(let postId):
            return "\(postId)"
        case .deletePostLike(let postId):
            return "\(postId)/likes"
        case .deletePostBookmark(let postId):
            return "\(postId)/bookmarks"
        case .deletePost(let postId):
            return "\(postId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllPost:
            return .get
        case .getDetailPost:
            return .get
        case .deletePostLike:
            return .delete
        case .deletePostBookmark:
            return .delete
        case .deletePost:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getAllPost:
            return .requestPlain
        case .getDetailPost:
            return .requestPlain
        case .deletePostLike:
            return .requestPlain
        case .deletePostBookmark:
            return .requestPlain
        case .deletePost:
            return .requestPlain
        }
    }
}


