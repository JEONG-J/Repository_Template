//
//  LocationMapAnnotationView.swift
//  VINNY
//
//  Created by 홍지우 on 7/15/25.
//

import SwiftUI

enum Category: String {
    case military
    case amekaji
    case street
    case outdoor
    case casual
    case denim
    case highend
    case workwear
    case leather
    case sporty
    case western
    case y2k

    var emoji: String {
        switch self {
        case .military: return "🪖"
        case .amekaji: return "🇺🇸"
        case .street: return "🛹"
        case .outdoor: return "🏔️"
        case .casual: return "👕"
        case .denim: return "👖"
        case .highend: return "💼"
        case .workwear: return "⚒️"
        case .leather: return "👞"
        case .sporty: return "🏃‍♂️"
        case .western: return "🐴"
        case .y2k: return "👚"
        }
    }
}

extension Category {
    static func fromAPI(_ raw: String?) -> Category {
        switch raw?.lowercased() {
        case "밀리터리": return .military
        case "아메카지":  return .amekaji
        case "스트릿":   return .street
        case "아웃도어":  return .outdoor
        case "캐주얼":   return .casual
        case "데님":    return .denim
        case "하이엔드":  return .highend
        case "워크웨어": return .workwear
        case "레더":  return .leather
        case "스포티":   return .sporty
        case "웨스턴":  return .western
        case "Y2k":      return .y2k
        default:         return .casual
        }
    }
}


struct LocationMapAnnotationView: View {
    var category: Category
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            Image(isSelected ? "selectedMarker" : "marker")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(category.emoji)
                .font(.system(size: 14))
                .offset(y: -8)
        }
        .background(Color.clear)
    }
}
