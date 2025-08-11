import Foundation

struct ShopReviewResponse: Codable {
    
    //코스 ID
    let reviewId : Int
    let title : String
    let content : String
    let userName : String
    let elapsedTime : String
    let imageUrls : [String]
    
}
