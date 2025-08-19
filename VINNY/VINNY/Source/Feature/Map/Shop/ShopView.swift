//
//  ShopView.swift
//  VINNY
//
//  Created by 홍지우 on 7/16/25.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var container: DIContainer
    
    let shopId: Int
    @StateObject private var reviewsVM = ReviewsViewModel()
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var detail: ShopDetailDTO?   // 옵셔널 상태로 보관
    @State private var isLoved: Bool = false     // ← 

    @State private var showDeleteDialog = false
    @State private var reviewToDelete: ShopReview?
    
    private var coords: (lat: Double, lng: Double)? {
        guard let d = detail, let lat = d.latitude, let lng = d.longitude else { return nil }
        return (lat, lng)
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 상단 바
                ZStack {
                    HStack {
                        Button {
                            container.navigationRouter.pop()
                        } label: {
                            Image("arrowBack").resizable().frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                    Text("빈티지샵 보기")
                        .font(.suit(.regular, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .padding(16)
                
                Divider()
                
                // 본문
                if isLoading {
                    ProgressView().padding(.top, 24)
                } else if let d = detail {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // 대표 이미지
                            if let first = d.images?.first, !first.url.isEmpty, let url = URL(string: first.url) {
                                AsyncImage(url: url) { img in
                                    img.resizable()
                                } placeholder: {
                                    Image("emptyBigImage").resizable()
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            } else {
                                Image("emptyBigImage")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            
                            HStack(spacing: 8) {
                                if let url = URL(string: d.logoImage) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let img):
                                            img.resizable()
                                        default:
                                            Image("emptyImage").resizable()
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Image("emptyImage")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(d.name)               // 서버 응답 필드에 맞춰 표시
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.contentBase)
                                    Text(d.address ?? "-")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.contentAdditive)
                                }
                                Spacer()
                                Button(action: {
                                    Task {
                                        do {
                                            _ = try await ShopAPITarget.toggleShopLove(shopId: shopId, isLoved: isLoved)
                                            isLoved.toggle()
                                        } catch {
                                            print("toggleFavorite failed:", error)
                                        }
                                    }
                                }) {
                                    Image(isLoved ? "likeFill" : "like")
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
                                Text(d.instagram ?? "-")
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
                                Text("\(d.openTime ?? "-") ~ \(d.closeTime ?? "-")")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.contentAdditive)
                                    .padding(.horizontal, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            
                            HStack {
                                HStack(spacing: 4) {
                                    Image("mapPin")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    Text(d.region ?? "-")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.contentAdditive)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(Color.backFillRegular)
                                )
                                
                                ForEach(d.shopVintageStyleList ?? [], id: \.self) { style in
                                    TagComponent(tag: style.vintageStyleName)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("소개")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.contentBase)
                                    Text((d.intro?.isEmpty == false ? d.intro : d.description) ?? "-")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.contentAdditive)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        CustomTabView(
                            shopId: shopId,
                            reviewsVM: reviewsVM,
                            photos: (d.images ?? []).filter { $0.main == false }.map { $0.url }
                        ) { review in
                            reviewToDelete = review
                            showDeleteDialog = true
                        }
                    }
                } else if let err = errorMessage {
                    Text(err).foregroundStyle(.red).padding(.top, 24)
                }
                    
                // 하단 버튼(기존 유지)
                HStack(spacing: 8) {
                    Button {
                        container.navigationRouter.push(to: .UploadReviewView(shopId: shopId))
                    } label: {
                        Text("후기 작성")
                            .font(.suit(.medium, size: 16))
                            .foregroundStyle(Color.contentBase)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(Color.backFillRegular))
                    }
                    
                    Button {
                        // 예시 좌표
                        if let c = coords {
                            MapViewModel().KaKaoMap(lat: c.lat, lng: c.lng)
                        }
                        
                    } label: {
                        Text("길찾기")
                            .font(.suit(.medium, size: 16))
                            .foregroundStyle(Color.contentInverted)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(Color.backFillInverted))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.backFillStatic)
                .navigationBarBackButtonHidden()
                // ✅ 여기서 로드 (ViewModel 없이)
                .task(id: shopId) { await fetch() }
            }
            if showDeleteDialog, let r = reviewToDelete {
                ReviewDeleteView(
                    isShowing: $showDeleteDialog,
                    shopId: shopId,
                    reviewId: r.reviewId,
                    reviewsVM: reviewsVM
                )
            }
        }
        .background(Color.backFillStatic)
    }

    @MainActor
    private func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let d = try await ShopAPITarget.getDetail(shopId: shopId)
            detail = d
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
