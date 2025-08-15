//
//  Shop.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//
// Shop.swift  ✅ 교체
import SwiftUI

struct Shops: Identifiable, Hashable {
    /// UI identity (stable per item instance)
    let id = UUID()
    /// 백엔드 shopId (Routing/API에 사용)
    let shopId: Int
    let name: String
    let address: String
    let tags: [String]
    let imageUrl: String?

    // 더미 예시(임시): 실제 앱에선 안 씀
    static let dummyList: [Shops] = [
        Shops(shopId: 1, name: "망원빈티지", address: "서울특별시 마포구 망원동 376-6", tags: ["지역", "스트릿", "데님"], imageUrl: nil),
        Shops(shopId: 2, name: "홍대빈티지", address: "서울 마포구 와우산로 21길 16", tags: ["캐쥬얼", "빈티지", "아메카지"], imageUrl: nil),
    ]
}

extension Shops {
    init(from dto: ShopSearchResultDTO) {
        // region + styles를 태그로 합치고 싶으면 아래처럼
        var t = dto.styles
        if let r = dto.region, !r.isEmpty { t.insert(r, at: 0) }

        self.init(
            shopId: dto.id,
            name: dto.name,
            address: dto.address,
            tags: t,
            imageUrl: dto.imageUrl
        )
    }
}
