//
//  ShopInfoSheet.swift
//  VINNY
//
//  Created by 홍지우 on 7/11/25.
//

import SwiftUI
import Kingfisher

struct ShopInfoSheet: View {
    @EnvironmentObject var container: DIContainer
    var shopName: String
    var shopAddress: String
    var shopIG: String
    var shopTime: String
    var categories: [String]
    var imageURL: URL? = nil
    
    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    ZStack {
                        if let url = imageURL {
                            KFImage(url)
                                .placeholder {
                                    // 로딩 중 동그란 스켈레톤
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .fade(duration: 0.15)        // 부드러운 페이드 (옵션)
                                .cancelOnDisappear(true)
                                .resizable()
                                .scaledToFill()               // 꽉 채우기
                        } else {
                            Image("emptyImage")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 40, height: 40)            // 이미지/플레이스홀더 동일 크기
                    .clipShape(Circle())                      // 바깥에서 원형 클립(항상 원)
                    .overlay(Circle().stroke(.black.opacity(0.06), lineWidth: 1)) // 옵션: 테두리
                    .contentShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(shopName)")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.contentBase)
                        Text("\(shopAddress)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.contentAdditive)
                    }
                    Spacer()
                    Button(action: {
                        container.navigationRouter.push(to: .ShopView(id: 0)) // TODO: 실제 shopId로 교체
                    }) {
                        Image("chevron.right")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                HStack(spacing: 2) {
                    Image("instargram")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("인스타그램")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.contentAssistive)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: 82, alignment: .leading)
                    Text("\(shopIG)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.contentAdditive)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                HStack(spacing: 2) {
                    Image("time")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("영업 시간")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.contentAssistive)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: 82, alignment: .leading)
                    Text("\(shopTime)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.contentAdditive)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                
                HStack {
                    HStack(spacing: 4) {
                        Image("mapPin")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("지역")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.contentAdditive)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(Color.backFillRegular)
                    )
                    
                    ForEach(categories, id: \.self) { category in
                        TagComponent(tag: category)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let url = imageURL {
                    KFImage(url)
                        .placeholder { Image("checkerImage").resizable() } // 로딩 중엔 체크 이미지
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .clipped()
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                } else {
                    // URL 없을 때만 체크 이미지
                    Image("checkerImage")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                Spacer()
            }
            .padding(.top, 4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.backFillStatic)
            )
        .ignoresSafeArea()
    }
}

//#Preview {
//    ShopInfoSheet()
//}
