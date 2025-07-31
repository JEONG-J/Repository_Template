//
//  SearchResultCell 2.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//


import SwiftUI

struct SearchResultCell: View {
    let shops: Shops

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // 썸네일 이미지 (없으면 placeholder)
                /*if let imageURL = shop.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))*/
               // } else{
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(shops.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(shops.address)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }

            // 태그들
            HStack(spacing: 6) {
                Label("지역", systemImage: "mappin.and.ellipse")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .labelStyle(.titleOnly)

                Text("카테고리1")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Text("카테고리2")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Text("카테고리3")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
       // .padding()
       // .background(Color(black))
       // .cornerRadius(12)
    }

