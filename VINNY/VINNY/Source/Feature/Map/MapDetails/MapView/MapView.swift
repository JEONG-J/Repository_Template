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
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if locationManager.currentLocation != nil {
                UIKitDarkMapView(viewModel: viewModel)
            } else {
                ProgressView("위치 정보를 불러오는 중...")
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
        // 마커 눌렀을 시 바텀 시트
        .sheet(item: $viewModel.selectedMarker) { marker in
            ShopInfoSheet(shopName: marker.title)
                .presentationDetents([.height(300)])
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .background(Color.backFillStatic)
    }
}

//#Preview {
//    MapView()
//}
