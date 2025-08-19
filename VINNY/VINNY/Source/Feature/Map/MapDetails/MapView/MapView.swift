//
//  MapView.swift
//  VINNY
//
//  Created by 홍지우 on 7/10/25.
//

/// 지도 화면 컨테이너: 상단바/지도/오버레이(버튼, 시트) 구성
import SwiftUI
import MapKit
import UIKit

struct MapView: View {
    // MARK: - Dependencies
    @Bindable private var locationManager = LocationManager.shared
    @ObservedObject private var viewModel: MapViewModel
    
    // MARK: - UI State
    @State private var dragOffset: CGFloat = 0

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    // 지도/프로그레스
                    if locationManager.currentLocation != nil {
                        UIKitDarkMapView(viewModel: viewModel)
                    } else {
                        ProgressView("위치 정보를 불러오는 중...")
                    }
                    
                    // 하단 유틸 버튼
                    HStack(spacing: 8) {
                        Button(action: {
                            viewModel.toggleFavorites()
                        }) {
                            Image(viewModel.showingFavorites ? "selectedStar" : "star")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(Color.backFillRegular)
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            LocationManager.shared.startUpdatingLocation() // 위치 정보 최신화
                            
                            // 현재 위치가 있을면 지도에 전달
                            if let location = LocationManager.shared.currentLocation {
                                NotificationCenter.default.post(name: .moveMapToCurrentLocation, object: location)
                                
                                // 지도 이동 허용 (추적 모드 활성화)
                                NotificationCenter.default.post(name: .setMapTrackingEnabled, object: true)
                            }
                        }) {
                            Image("icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(Color.backFillInteractive)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, viewModel.selectedMarker != nil ? 380 : 85)
                    
                    // 바텀시트
                    if let d = viewModel.selectedShopDetail, viewModel.selectedMarker != nil {
                        // 1) 로컬 상수로 쪼개서 타입 확정
                        let urlStr: String? = d.images.first(where: { $0.isMainImage })?.url ?? d.images.first?.url
                        let mainURL: URL?   = urlStr.flatMap(URL.init(string:))
                        let shopId: Int     = d.id
                        let shopName: String = d.name
                        let shopAddress: String = d.address
                        let shopIG: String      = d.instagram
                        let shopTime: String    = "\(d.openTime) ~ \(d.closeTime)"
                        let categories: [String] = d.styles.map { $0.vintageStyleName }
                        let logoURL: URL? = d.logoImage.isEmpty ? nil : URL(string: d.logoImage)

                        // 2) 바인딩한 d를 non-optional로 그대로 사용
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    if let marker = viewModel.selectedMarker {
                                        NotificationCenter.default.post(name: .deselectMarkerAndRefresh, object: marker)
                                    }
                                    withAnimation { viewModel.selectedMarker = nil }
                                }
                            )

                        ShopInfoSheet(
                            shopId:       shopId,
                            shopName:     shopName,
                            shopAddress:  shopAddress,
                            shopIG:       shopIG,
                            shopTime:     shopTime,
                            categories:   categories,
                            logoImageURL: logoURL,
                            imageURL:     mainURL
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .offset(y: dragOffset)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedMarker != nil)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height > 0 { dragOffset = value.translation.height }
                                }
                                .onEnded { value in
                                    if value.translation.height > 120 {
                                        if let marker = viewModel.selectedMarker {
                                            NotificationCenter.default.post(name: .deselectMarkerAndRefresh, object: marker)
                                        }
                                        withAnimation {
                                            viewModel.selectedMarker = nil
                                            viewModel.selectedShopDetail = nil
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation { dragOffset = 0 }
                                    }
                                }
                        )
                    }
                }
            }
            
            MapTopView()
        }
        // MARK: Lifecycle
        .onAppear {
            if viewModel.showingFavorites {
                viewModel.showingFavorites = false
            }
            viewModel.fetchShops()
        }
        .onDisappear {
            viewModel.showingFavorites = false
            viewModel.selectedMarker = nil
            viewModel.selectedShopDetail = nil
        }
        .task {
            // 최초 1회 카메라 이동
            if !viewModel.hasSetInitialRegion,
               let location = locationManager.currentLocation {
                viewModel.shouldTrackUserLocation = true
                viewModel.updateFromLocation(location)
                viewModel.hasSetInitialRegion = true
            }
            viewModel.fetchShops()
        }
        // 위치 바뀔 때 최초 1회 자동 이동 (중복 방지)
        .onChange(of: locationManager.currentLocation) { oldLocation, newLocation in
            guard !viewModel.hasSetInitialRegion, let location = newLocation else { return }
            viewModel.updateFromLocation(location)
            viewModel.hasSetInitialRegion = true
        }
        // "현 위치에서 검색" 클릭 시 자동 이동 허용
        .onReceive(NotificationCenter.default.publisher(for: .setMapTrackingEnabled)) { notification in
            viewModel.shouldTrackUserLocation = true
        }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    MapView()
//}
