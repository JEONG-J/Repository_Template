import Foundation

struct ResetVintageStyleRequestDTO: Encodable {
    let vintageStyleIds: [Int]
}

struct ResetVintageItemRequestDTO: Encodable {
    let vintageItemIds: [Int]
}

struct ResetRegionRequestDTO: Encodable {
    let regionIds: [Int]
}

struct ResetBrandRequestDTO: Encodable {
    let brandIds: [Int]
}


