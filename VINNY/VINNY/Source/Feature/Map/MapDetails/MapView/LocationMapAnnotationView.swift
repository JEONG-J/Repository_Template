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
