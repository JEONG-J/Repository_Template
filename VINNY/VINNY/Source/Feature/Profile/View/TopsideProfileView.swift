//
//  TopsideProfileView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI

struct TopsideProfileView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    var body: some View {
        ZStack(alignment: .top) {
            // 배경 이미지
            Image("example_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 상단 바
                HStack {
                    Text("프로필")
                        .font(.suit(.bold, size: 24))
                        .foregroundStyle(Color("ContentBase"))
                    Spacer()
                    Button(action: {
                        container.navigationRouter.push(to: .SettingView)
                    }) {
                        Image("settingbutton")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color("ContentBase"))
                    }
                }
                .padding(.top, 13)
                .padding(.horizontal, 16)

                Spacer()
                
                // 하단 프로필 섹션
                HStack(alignment: .center, spacing: 12) {
                    Image("example_profile")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .padding(.leading, 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("조휴일")
                            .font(.suit(.medium, size: 18))
                            .foregroundStyle(Color("ContentBase"))
                        Text("개펑크정신")
                            .font(.suit(.regular, size: 12))
                            .foregroundStyle(Color("ContentAdditive"))
                    }

                    Spacer()

                    Button {
                        // 편집 액션
                    } label: {
                        HStack(spacing: 2) {
                            Image("pencil")
                            Text("편집")
                        }
                        .font(.suit(.medium, size: 14))
                        .foregroundStyle(Color("ContentBase"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.backFillRegular)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 10)
            }
        }
    }
}

