//  서버 주소 및 각 API의 Endpoint 경로를 한 곳에서 관리하는 파일.
//  API 경로가 분산되지 않도록 중앙 집중화하여 유지보수성을 높이기 위한 목적.

import Foundation

public struct API {
    
    /// 전체 서버의 공통 Base URL
    /// 각 Feature API의 path는 이 baseURL에 붙여서 구성
    public static let baseURL = "https://app.vinnydesign.net/api"

    // MARK: - 주요 기능별 Endpoint 경로

//    예시
//    static let courseURL = "\(baseURL)/courses"
    // 유저 정보 관련 API
    static let userURL = "\(baseURL)/users/"
    //검색 관련 API
    static let searchURL = "\(baseURL)/search/"
    //게시물 관련 API
    static let postURL = "\(baseURL)/posts/"
    //가게 정보 관련 API
    static let shopURL = "\(baseURL)/shops/"
    //프로필 관련 API
    static let mypageURL = "\(baseURL)/mypage"
    
    static let authURL = "\(baseURL)auth/"

    //map 관련 API
    static let mapURL = "\(baseURL)/map/"


    
}

