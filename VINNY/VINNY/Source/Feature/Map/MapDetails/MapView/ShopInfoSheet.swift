//
//  ShopInfoSheet.swift
//  VINNY
//
//  Created by 홍지우 on 7/11/25.
//

import SwiftUI

struct ShopInfoSheet: View {
    let shopName: String
    var shopAddress: String = "샵 주소"
    var shopIG: String = "vintageplus_trendy"
    var shopTime: String = "오후 12시 ~ 오후 11시"
    var categories: [String] = ["카테고리1", "카테고리2", "카테고리3"]
    
    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image("emptyImage")
                        .resizable()
                        .frame(width: 40, height: 40)
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
                
                Image("checkerImage")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
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
