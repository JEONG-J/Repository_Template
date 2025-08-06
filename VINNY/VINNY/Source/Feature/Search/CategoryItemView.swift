//
//  CategoryItemView.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//


import SwiftUI

struct CategoryItemView: View {
    let categoryItem: CategoryItem

    var body: some View {
        ZStack {
            Image(categoryItem.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 115, height: 115)
                .clipped()

            Text("\(categoryItem.emoji) \(categoryItem.name)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .shadow(radius: 1)
                .multilineTextAlignment(.center)
        }
        .frame(width: 115, height: 115)
        .cornerRadius(8)
    }
}
