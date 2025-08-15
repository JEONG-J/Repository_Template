import Foundation

struct MapAllResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ShopItem]
}
struct ShopItem: Decodable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let vintageStyleList: [StyleItem]
}
struct StyleItem: Decodable {
    let id: Int
    let vintageStyleName: String
}

struct GetSavedShopDTO: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let style: [String]
}

struct GetShopOnMapDTO: Decodable {
    let id: Int
    let name: String
    let openTime: String
    let closeTime: String
    let instagram: String
    let address: String
    let latitude: Double
    let longitude: Double
    let region: String
    let images: [ShopImage] //수정 가능성 있음
    let styles: [String]
}

struct ShopImage: Decodable {
    let url: String
    let isMainImage: Bool
}
