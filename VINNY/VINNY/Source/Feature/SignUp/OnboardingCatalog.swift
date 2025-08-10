//
//  OnboardingCatalog.swift
//  VINNY
//
//  Created by 소민준 on 8/9/25.
//

import Foundation

/// 화면에 표시할 옵션(타이틀) + 서버 DB id
struct OnboardOption: Identifiable, Hashable {
    let id: Int          // 서버 id
    let title: String    // UI 표시용 (이모지 포함 가능)
}

enum OnboardingCatalog {
    // MARK: - 스타일 (빈티지 취향) — 스펙 확정판
    
    static let styles: [OnboardOption] = [
        .init(id: 1,  title: "🪖 밀리터리"),
        .init(id: 2,  title: "🇺🇸 아메카지"),
        .init(id: 3,  title: "🛹 스트릿"),
        .init(id: 4,  title: "🏔️ 아웃도어"),
        .init(id: 5,  title: "👕 캐주얼"),
        .init(id: 6,  title: "👖 데님"),
        .init(id: 7,  title: "💼 하이엔드"),
        .init(id: 8,  title: "🛠️ 워크웨어"),
        .init(id: 9,  title: "👞 레더"),
        .init(id: 10, title: "🏃‍♂️ 스포티"),
        .init(id: 11, title: "🐴 웨스턴"),
        .init(id: 12, title: "👚 Y2K"),
        .init(id: 13, title: "기타")
    ]

    // MARK: - 브랜드
    static let brands: [OnboardOption] = [
        .init(id: 1,  title: "리바이스"),
        .init(id: 2,  title: "랭글러"),
        .init(id: 3,  title: "칼하트"),
        .init(id: 4,  title: "디키즈"),
        .init(id: 5,  title: "폴로"),
        .init(id: 6,  title: "라코스테"),
        .init(id: 7,  title: "나이키"),
        .init(id: 8,  title: "아디다스"),
        .init(id: 9,  title: "스투시"),
        .init(id: 10, title: "베이프"),
        .init(id: 11, title: "슈프림"),
        .init(id: 12, title: "노스페이스"),
        .init(id: 13, title: "파타고니아"),
        .init(id: 14, title: "마르지엘라"),
        .init(id: 15, title: "디젤"),
        .init(id: 16, title: "버버리"),
        .init(id: 17, title: "아비렉스"),
        .init(id: 18, title: "기타")
    ]

    // MARK: - 빈티지 아이템(옷)
    static let items: [OnboardOption] = [
        .init(id: 1, title: "아우터"),
        .init(id: 2, title: "상의"),
        .init(id: 3, title: "하의"),
        .init(id: 4, title: "모자"),
        .init(id: 5, title: "신발"),
        .init(id: 6, title: "악세서리"),
        .init(id: 7, title: "잡화"),
        .init(id: 8, title: "기타")
    ]

    // MARK: - 지역
    static let regions: [OnboardOption] = [
        .init(id: 1, title: "홍대"),
        .init(id: 2, title: "성수"),
        .init(id: 3, title: "강남"),
        .init(id: 4, title: "이태원"),
        .init(id: 5, title: "동묘"),
        .init(id: 6, title: "합정"),
        .init(id: 7, title: "망원"),
        .init(id: 8, title: "명동")
    ]
}

// MARK: - 타이틀 → id 헬퍼 
extension OnboardingCatalog {
    /// "🛹 스트릿" / "스트릿" 둘 다 매칭되게 마지막 단어 기준으로 id 탐색
    private static func id(in options: [OnboardOption], from anyTitle: String) -> Int? {
        // "🛹 스트릿" → "스트릿"
        let key = anyTitle.split(separator: " ").last.map(String.init) ?? anyTitle
        return options.first { opt in
            let plain = opt.title.split(separator: " ").last.map(String.init) ?? opt.title
            return plain == key
        }?.id
    }
    static func styleId(from title: String)  -> Int? { id(in: styles,  from: title) }
    static func brandId(from title: String)  -> Int? { id(in: brands,  from: title) }
    static func itemId(from title: String)   -> Int? { id(in: items,   from: title) }
    static func regionId(from title: String) -> Int? { id(in: regions, from: title) }
}
