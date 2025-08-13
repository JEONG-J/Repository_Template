//
//  NavigationDestination.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation

enum NavigationDestination: Hashable {
    case SplashView
    case VinnyTabView
    case LoginView
    case SearchView
    case BrandView
    case CategoryView
    case ClothTypeView
    case LocationView
    case SearchFocusView
    case SearchResultView(keyword: String)
    case PostView
    case HomeView
    case CommunityView
    case PostUploadView
    case TasteResetView
    case SettingView
    case TopsideProfileView
    case MyProfileView
    case LastSignUpView
    case UploadReviewView
    case ShopView
    case RecommendView

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.SplashView, .SplashView):
            return true
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
        case(.SearchFocusView, .SearchFocusView):
            return true
        case(.SearchResultView, .SearchResultView):
            return true
        case (.PostView, .PostView):
            return true
        case (.HomeView, .HomeView):
            return true
        case (.CommunityView, .CommunityView):
            return true
        case (.PostUploadView, .PostUploadView):
            return true 
        case(.TasteResetView, .TasteResetView):
            return true
        case(.SettingView, .SettingView):
            return true
        case(.TopsideProfileView, .TopsideProfileView):
            return true
        case(.MyProfileView, .MyProfileView):
            return true
        case(.LastSignUpView, .LastSignUpView):
            return true
        case(.UploadReviewView, .UploadReviewView):
            return true
        case(.ShopView, .ShopView):
            return true
        case(.RecommendView, .RecommendView):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .SplashView:
            hasher.combine("SplashView")
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
        case .SearchFocusView:
            hasher.combine("SearchFocusView")
        case .SearchResultView:
            hasher.combine("SearchResultView")
        case .CommunityView:
            hasher.combine("CommunityView")
        case .HomeView:
            hasher.combine("HomeView")
        case .PostView:
            hasher.combine("PostView")
        case .PostUploadView:
            hasher.combine("PostUploadView")
        case .TasteResetView:
            hasher.combine("TasteResetView")
        case .SettingView:
            hasher.combine("SettingView")
        case .TopsideProfileView:
            hasher.combine("TopsideProfileView")
        case .MyProfileView:
            hasher.combine("MyProfileView")
        case .LastSignUpView:
            hasher.combine("LastSignUpView")
        case .UploadReviewView:
            hasher.combine("UploadReviewView")
        case .ShopView:
            hasher.combine("ShopView")
        case .RecommendView:
            hasher.combine("RecommendView")
        }
    }
}
