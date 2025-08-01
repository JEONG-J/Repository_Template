//
//  VinnyTabCase.swift
//  VINNY
//
//  Created by 한태빈 on 7/4/25.
//

import Foundation
import SwiftUI

enum SBTabCase: String, CaseIterable {

    case home = "home"
    case map = "map"
    case community = "community"
    case myprofile = "myprofile"

    /// 이미지 asset의 이름 리턴
    var imageName: String {
        return self.rawValue
    }

    /// 이미지 asset의 이름 리턴
    var selectedImageName: String {
        return self.imageName + "_selected"
    }
    
    var title: String {
        switch self{
        case .home: return "홈"
        case .map: return "지도"
        case .community: return "커뮤니티"
        case .myprofile: return "프로필"
        }
    }

    /// 탭 아이템에 해당하는 콘텐트 뷰
    func contentView(container: DIContainer) -> some View {
        switch self {
        case .home:
            return AnyView(HomeView())
        case .map:
            return AnyView(MapView())
        case .community:
            return AnyView(CommunityView())
        case .myprofile:
            return AnyView(MyProfileView(container: container))
        }
    }

}
