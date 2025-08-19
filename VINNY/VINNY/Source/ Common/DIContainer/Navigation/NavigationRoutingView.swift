//
//  NavigationRoutingView.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import SwiftUI

struct NavigationRoutingView: View {
    
    @EnvironmentObject var container: DIContainer
    
    @State var destination: NavigationDestination
    @State private var deleteShowing: Bool = true
    
    var body: some View {
        switch destination {
        case .SplashView:
            SplashView(container: container)
                .environmentObject(container)
        case .VinnyTabView:
            VinnyTabView(container: container)
                .environmentObject(container)
        case .LoginView:
            LoginView(container: container)
                .environmentObject(container)
        case .SearchView:
            SearchView()
                .environmentObject(container)
        case .BrandView:
            BrandView(container: container)
                .environmentObject(container)
        case .CategoryView:
            CategoryView(container: container)
                .environmentObject(container)
        case .ClothTypeView:
            ClothTypeView(container: container)
                .environmentObject(container)
        case .LocationView:
            LocationView(container: container)
                .environmentObject(container)
        case .SearchFocusView:
            SearchFocusView()
                .environmentObject(container)
            
        case .SearchResultView(let keyword):
            SearchResultView(keyword: keyword)
        case .PostView(let id):
            PostView(postId: id)
                .environmentObject(container)
        case .HomeView:
            HomeView(container: container)
                .environmentObject(container)
        case .CommunityView:
            CommunityView(container: container)
                .environmentObject(container)
        case .PostUploadView:
            PostUploadView(container: container)
        case .SettingView:
            SettingView(container: container)
                .environmentObject(container)
        case .TopsideProfileView:
            TopsideProfileView()
                .environmentObject(container)
        case .MyProfileView:
            MyProfileView()
                .environmentObject(container)
        case .TasteResetView:
            TasteResetView(container: container)
                .environmentObject(container)
        case .LastSignUpView:
            LastSignUpView(container: container)
                .environmentObject(container)
        case .UploadReviewView(let shopId):
            UploadReviewView(shopId: shopId)
                .environmentObject(container)
        case .ShopView(let id):
            ShopView(shopId: id)
                .environmentObject(container)
        case .RecommendView:
            RecommendView(container: container)
                .environmentObject(container)
        case .NotificationView:
            NotificationView(container: container)
                .environmentObject(container)
        case .PostEditView(let postId):
            PostEditView()
                .environmentObject(container)
        case .PostDeleteView(let postId):
            PostDeleteView(isShowing: $deleteShowing)
                .environmentObject(container)
                .onAppear { container.editingPostId = postId }
                .onChange(of: deleteShowing) { newValue in
                    if newValue == false {
                        container.navigationRouter.pop()
                    }
                }
        }
    }
    
}
