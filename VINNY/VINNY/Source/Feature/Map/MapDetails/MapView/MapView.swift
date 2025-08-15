//
//  MapView.swift
//  VINNY
//
//  Created by 홍지우 on 7/10/25.
//

/// Map을 띄우고, ViewModel의 바인딩 상태를 보여주는 역할
/// ViewModel의 데이터를 바인딩 해 뷰를 자동 업데이트 함.
import SwiftUI
import MapKit
import UIKit

struct MapView: View {
    
    @Bindable private var locationManager = LocationManager.shared
    @ObservedObject private var viewModel: MapViewModel
    
    @State private var dragOffset: CGFloat = 0

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    if locationManager.currentLocation != nil {
                        UIKitDarkMapView(viewModel: viewModel)
                    } else {
                        ProgressView("위치 정보를 불러오는 중...")
                    }
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            
                        }) {
                            Image("star")
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
                    
                    // 마커 눌렀을 떄 효과 (커스텀)
                    if let marker = viewModel.selectedMarker {
                        let d = viewModel.selectedShopDetail
                        
                        // 대표 이미지 url 계산
                        let mainURLString = d?.images.first(where: {$0.isMainImage})?.url ?? d?.images.first?.url
                        let mainURL = mainURLString.flatMap(URL.init(string:))
                        
                        // 터치 감지는 따로 TapGesture만 담당
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        if let marker = viewModel.selectedMarker {
                                            NotificationCenter.default.post(name: .deselectMarkerAndRefresh, object: marker)
                                        }
                                        withAnimation {
                                            viewModel.selectedMarker = nil
                                        }
                                    }
                            )
                        
                        ShopInfoSheet(
                            shopName:     d?.name ?? "",
                            shopAddress:  d?.address ?? "정보 없음",
                            shopIG:       d?.instagram ?? "",
                            shopTime:     d.map { "\($0.openTime) ~ \($0.closeTime)" } ?? "정보 없음",
                            categories:   d?.styles.map { $0.vintageStyleName } ?? [],
                            imageURL: mainURL
                        )
                            .frame(maxWidth: .infinity)
                            .frame(height: 380)
                            .offset(y: dragOffset)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedMarker)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            dragOffset = value.translation.height
                                        }
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
                                            withAnimation {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )
                    }
                }
            }
            
            MapTopView()
        }
        // 최초 진입 시 1회만 지도 카메라 이동
        .onAppear {
            if !viewModel.hasSetInitialRegion,
               let location = locationManager.currentLocation {
                viewModel.shouldTrackUserLocation = true
                viewModel.updateFromLocation(location)
                viewModel.hasSetInitialRegion = true
            }
            viewModel.fetchShops()
        }
        // 위치 바뀔 때 최초 1회 자동 이동 (중복 방지)
        .onChange(of: locationManager.currentLocation) {
            if !viewModel.hasSetInitialRegion,
               let location = locationManager.currentLocation {
                viewModel.updateFromLocation(location)
                viewModel.hasSetInitialRegion = true
            }
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
