//
//  ReviewsView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

struct ReviewsView: View {
    @ObservedObject var viewModel: ReviewsViewModel
    var onTapDelete: (ShopReview) -> Void = { _ in }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().padding(.top, 24)
            } else if let err = viewModel.errorMessage {
                Text(err).foregroundStyle(.red).padding(.top, 24)
            } else if viewModel.reviews.isEmpty {
                EmptyView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.reviews) { r in
                        ReviewsCard(r)
                    }
                }
            }
        }
    }
    
    private func ReviewsCard(_ r: ShopReview) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image("emptyImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(r.userName)
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color.contentBase)
                    Text(r.userName)
                        .font(.suit(.regular, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                
                Spacer()
                
                Button(action: {
                    onTapDelete(r)
                }) {
                    Image("close")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            VStack (alignment: .leading, spacing: 2) {
                Text(r.elapsedTime)
                    .font(.suit(.regular, size: 12))
                    .foregroundStyle(Color.contentAssistive)
                Text(r.title)
                    .font(.suit(.regular, size: 18))
                    .foregroundStyle(Color.contentBase)
                Text(r.content)
                    .font(.suit(.regular, size: 14))
                    .foregroundStyle(Color.contentAdditive)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            if !r.imageUrls.isEmpty {
                let ratio: CGFloat = 3.0/2.0

                let w = (UIScreen.main.bounds.width - 32 - 12) / 2
                let h = w / ratio
                if r.imageUrls.count == 1, let s = r.imageUrls.first, let url = URL(string: s) {
                    HStack(spacing: 0) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Image("emptyBigImage")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: w, height: h)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                } else {
                    HStack(spacing: 12) {
                        ForEach(r.imageUrls.prefix(2), id: \.self) { s in
                            if let url = URL(string: s) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Image("emptyBigImage")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                                .frame(width: w, height: h)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            
            Divider()
        }
    }
}

#Preview {
    ReviewsView(viewModel: ReviewsViewModel())
}
