//
//  NavigationDestination.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation

enum NavigationDestination: Hashable {
    
    case VinnyTabView
    case LoginView
    case SearchView
    case BrandView
    case CategoryView
    case ClothTypeView
    case LocationView
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.VinnyTabView, .VinnyTabView):
              return true
        case (.LoginView, .LoginView):
              return true
        case (.SearchView, .SearchView):
                return true
        case(.BrandView, .BrandView):
            return true
        case(.CategoryView, .CategoryView):
            return true
        case(.ClothTypeView, .ClothTypeView):
            return true
        case(.LocationView, .LocationView):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .VinnyTabView:
            hasher.combine("VinnyTabView")
        case .LoginView:
            hasher.combine("LoginView")
        case .SearchView:
            hasher.combine("SearchView")
        case .BrandView:
            hasher.combine("BrandView")
        case .CategoryView:
            hasher.combine("CategoryView")
        case .ClothTypeView:
            hasher.combine("ClothTypeView")
        case .LocationView:
            hasher.combine("LocationView")
        }
    }
}
