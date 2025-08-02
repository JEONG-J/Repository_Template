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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image("example_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(shops.name)
                        .font(.suit(.bold, size: 26))
                        .foregroundColor(.contentBase)
                    
                    Text(shops.address)
                        .font(.suit(.regular, size: 14))
                        .foregroundColor(.contentAdditive)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    
            }
            
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 13))
                    .foregroundColor(.contentAdditive)
                Text(shops.address)
                    .font(.suit(.regular, size: 13))
                    .foregroundColor(.contentAdditive)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
