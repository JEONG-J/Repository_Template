//
//  OnboardingSelection.swift
//  VINNY
//
//  Created by 소민준 on 8/9/25.
//


import Foundation

/// 온보딩 과정에서 모은 **서버 id** 선택값
struct OnboardingSelection {
    var vintageStyleIds: Set<Int> = []   // CategoryView  (min 1, max 3)
    var brandIds: Set<Int> = []          // BrandView     (min 1, max 5)
    var vintageItemIds: Set<Int> = []    // ClothTypeView (min 1, max 3)
    var regionIds: Set<Int> = []         // LocationView  (min 1, max 3)

    // MARK: - Constraints
    enum Limit {
        static let styleMin = 1, styleMax = 3
        static let brandMin = 1, brandMax = 5
        static let itemMin  = 1, itemMax  = 3
        static let areaMin  = 1, areaMax  = 3
    }

    // MARK: - Validation helpers
    var isStyleValid: Bool { (Limit.styleMin...Limit.styleMax).contains(vintageStyleIds.count) }
    var isBrandValid: Bool { (Limit.brandMin...Limit.brandMax).contains(brandIds.count) }
    var isItemValid:  Bool { (Limit.itemMin...Limit.itemMax).contains(vintageItemIds.count) }
    var isAreaValid:  Bool { (Limit.areaMin...Limit.areaMax).contains(regionIds.count) }
    var isAllValid:   Bool { isStyleValid && isBrandValid && isItemValid && isAreaValid }

    mutating func reset() {
        vintageStyleIds.removeAll()
        brandIds.removeAll()
        vintageItemIds.removeAll()
        regionIds.removeAll()
    }
}

/// 공용 토글 유틸 (상한선 고려)
extension Set where Element == Int {
    mutating func toggleWithCap(_ id: Int, max: Int) {
        if contains(id) { remove(id) }
        else if count < max { insert(id) }
    }
}
