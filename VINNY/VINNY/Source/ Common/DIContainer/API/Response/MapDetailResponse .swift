import Foundation

struct MapAllResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ShopItem]
    let timestamp: String?
}
struct ShopItem: Decodable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let vintageStyleList: [StyleItem]
}

struct StyleItem: Decodable, Hashable {
    let id: Int
    let vintageStyleName: String
}

struct GetSavedShopDTO: Decodable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let vintageStyleList: [VintageStyleDTO]
    let mainVintageStyle: VintageStyleDTO?
    
    var style: [String] { vintageStyleList.map(\.vintageStyleName) }
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
    let logoImage: String
    let images: [ShopImage] //수정 가능성 있음
    let styles: [StyleItem]
    
    private enum CodingKeys: String, CodingKey {
        case id, name, openTime, closeTime, instagram, address, latitude, longitude, region, logoImage, images
        case styles = "shopVintageStyleList"
    }
}

struct ShopImage: Decodable {
    let url: String
    let isMainImage: Bool
    
    private enum CodingKeys: String, CodingKey {
        case url
        case isMainImage = "main"
    }
}

struct MapEnvelope<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T
    let timestamp: String?
}
