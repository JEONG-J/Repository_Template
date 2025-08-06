import Foundation

struct PostDetailResponse: Codable {
    
    // 공통 부분 빼고 다 적으면 됨
    let courseId: Int
    let courseImage: String
    let courseName: String
    let courseDescription: String
    let courseType: String
    let rating: Int
    let reviewCount: Int
    let recommendTime: String
    let participantsNumber: Int
    let isBookMarked: Bool
    let placeInfos: [PlaceInfo]
    
}

struct PlaceInfo: Identifiable, Codable {
    
    let id = UUID() // 실제 응답 데이터에 id가 없어서 빼줘야 함
    
    let placeId: Int
    let placeName: String
    let placeLatitude: Double
    let placeLongitude: Double
    let isVisited: Bool
    
    enum CodingKeys: String, CodingKey {
        case placeId
        case placeName
        case placeLatitude
        case placeLongitude
        case isVisited
    }
    
}
