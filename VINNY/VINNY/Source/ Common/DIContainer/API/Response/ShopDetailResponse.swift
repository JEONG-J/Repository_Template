import Foundation

struct ReviewEnvelope<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T
    let timestamp: String?
}

struct ShopReview: Decodable, Identifiable, Hashable {
    //코스 ID
    var id: Int { reviewId }
    let reviewId : Int
    let title : String
    let content : String
    let userName : String
    let elapsedTime : String
    let imageUrls : [String]
}


