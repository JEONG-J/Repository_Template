//
//  PhotosView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct PhotosView: View {
    let urls: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(urls, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    PhotosView(urls: [])
}
