import Foundation

struct mySavedShop: Codable {
    let shopId: Int
    let name: String
    let address: String
    let region: String
    let styles: [String]
    let imageUrls: [String]
}
