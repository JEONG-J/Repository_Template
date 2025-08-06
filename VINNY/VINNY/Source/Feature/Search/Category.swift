//
//  Category.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//


struct CategoryItem: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let imageName: String

    static let sampleList: [CategoryItem] = [
        CategoryItem(id: "military", name: "밀리터리", emoji: "🪖", imageName: "military"),
        CategoryItem(id: "amekaji", name: "아메카지", emoji: "🇺🇸", imageName: "amekaji"),
        CategoryItem(id: "street", name: "스트릿", emoji: "🛹", imageName: "street"),
        CategoryItem(id: "outdoor", name: "아웃도어", emoji: "🏔️", imageName: "outdoor"),
        CategoryItem(id: "casual", name: "캐주얼", emoji: "👕", imageName: "casual"),
        CategoryItem(id: "denim", name: "데님", emoji: "👖", imageName: "denim"),
        CategoryItem(id: "highend", name: "하이엔드", emoji: "💼", imageName: "highend"),
        CategoryItem(id: "workwear", name: "워크웨어", emoji: "🛠️", imageName: "workwear"),
        CategoryItem(id: "leather", name: "레더", emoji: "👞", imageName: "leather"),
        CategoryItem(id: "sporty", name: "스포티", emoji: "🏃‍♂️", imageName: "sporty"),
        CategoryItem(id: "western", name: "웨스턴", emoji: "🐴", imageName: "western"),
        CategoryItem(id: "Y2K", name : "Y2K", emoji: "👚", imageName: "Y2K")
    ]
}
