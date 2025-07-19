//
//  CustomTabView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI
import SwiftData

struct CustomTabView: View {
    @State var selectedFilter: Int = 0
    let filters: [String] = ["사진", "후기"]
    private var isReview: Bool = false
    private var reviewCount: Int = 59
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let tabSize = geometry.size.width / CGFloat(filters.count)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(filters.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedFilter = index
                                }
                            }) {
                                HStack {
                                    Text(filters[index])
                                        .font(selectedFilter == index ? .suit(.bold, size: 16) : .suit(.light, size: 16))
                                        .foregroundStyle(selectedFilter == index ? Color.contentBase : Color.contentDisabled)
                                    if filters[index] == "후기" {
                                        Text("\(reviewCount)개")
                                            .foregroundStyle(Color.contentAdditive)
                                            .font(.suit(.medium, size: 12))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .foregroundStyle(Color.backFillRegular)
                                            )
                                    }
                                }
                                .frame(width: tabSize)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    
                    //밑줄
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.contentDisabled)
                            .frame(height: 1)
                        
                        Rectangle()
                            .fill(Color.contentBase)
                            .frame(width: tabSize, height: 2)
                            .offset(x: CGFloat(selectedFilter) * tabSize, y: -1)
                            .animation(.easeInOut(duration: 0.25), value: selectedFilter)
                    }
                }
            }
            .frame(height: 55)
            
            
            if selectedFilter == 0 {
                PhotosView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ReviewsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.backFillStatic)
    }
}

#Preview {
    CustomTabView()
}
