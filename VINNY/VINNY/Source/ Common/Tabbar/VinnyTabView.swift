//
//  VinnyTabView.swift
//  VINNY
//
//  Created by 한태빈 on 7/4/25.
//

import SwiftUI

struct VinnyTabView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }

    // MARK: - @State
    /// 현재 탭
    @State private var selectedTab: SBTabCase = .home

    var body: some View {
        ZStack {
            selectedTab.contentView(container: container)

            VStack {
                Spacer()

                tabBar
            }
        }
        .background(Color.backRootRegular)

    }

    /// 탭 바
    private var tabBar: some View {
        HStack(alignment: .bottom) {
            ForEach(SBTabCase.allCases, id: \.rawValue) { tab in
                
                Spacer()

                Button(action: {
                    selectedTab = tab
                }) {
                    VStack {

                        Image(
                            selectedTab == tab ? tab.selectedImageName : tab.imageName
                        )
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.top, 20)
                        
                        Text(tab.title)
                            .font(.suit(.regular, size: 12))
                            .foregroundStyle(selectedTab == tab ? Color("ContentBase") : Color("ContentDisabled"))
                    }

                }

                Spacer()
            }
        }
        .frame(height: 70)
        .background(Color.backRootRegular)
    }
}

#Preview {
    let container = DIContainer()
    VinnyTabView(container: container)
        .environmentObject(container)
}
