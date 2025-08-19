//
//  CustomTabView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI
import SwiftData

struct CustomTabView: View {
    let shopId: Int
    @ObservedObject var reviewsVM: ReviewsViewModel 
    var onTapDelete: (ShopReview) -> Void = { _ in }

    var photos: [String]

    init(
        shopId: Int,
        reviewsVM: ReviewsViewModel,
        photos: [String] = [],
        onTapDelete: @escaping (ShopReview) -> Void = { _ in }
    ) {
        self.shopId = shopId
        self.reviewsVM = reviewsVM
        self.photos = photos
        self.onTapDelete = onTapDelete
    }
    @State var selectedFilter: Int = 0
    let filters: [String] = ["사진", "후기"]
    
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
                                        Text("\(reviewsVM.reviews.count)개")
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
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(photos, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2 - 24, height: UIScreen.main.bounds.width / 2 - 24)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            } else if selectedFilter == 1 {
                ReviewsView(viewModel: reviewsVM, onTapDelete: onTapDelete)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity)
            } else {
                EmptyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.backFillStatic)
        .task(id: shopId) {
            await reviewsVM.load(shopId: shopId)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didUploadReview)) { note in
            guard (note.object as? Int) == shopId else { return }
            Task { await reviewsVM.load(shopId: shopId) }
        }
    }
}

