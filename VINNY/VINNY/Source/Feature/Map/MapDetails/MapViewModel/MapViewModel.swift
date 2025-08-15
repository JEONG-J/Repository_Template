//
//  MapViewModel.swift
//  VINNY
//
//  Created by 홍지우 on 7/12/25.
//

/// 지도에서 보여줄 위치를 결정하는 MapCameraPosition, MKCoordinateRegion 등을 관리 함
import SwiftUI
import MapKit
import Observation
import KakaoMapsSDK

final class MapViewModel: ObservableObject {
    
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic) // 지도 카메라 위치. 기본은 사용자 위치
    @Published var currentMapCenter: CLLocationCoordinate2D? // 현재 지도의 중심 좌표 (내 위치 중심 or 마커 위치 등)
    
    // 지도에 표시 될 마커 목록 ( 나중에 API 연결해야 함)
    @Published var makers: [Marker] = [
        .init(coordinate: .init(latitude: 37.5551033, longitude: 126.9221464), title: "루트 홍대", category: .casual),
        .init(coordinate: .init(latitude: 37.5521997, longitude: 126.9209760), title: "도조&만쥬 빈티지샵", category: .street)
    ]
    
    @Published var selectedMarker: Marker? = nil // 사용자가 선택한 마커 → 바텀 시트로 노출됨
    @Published var hasSetInitialRegion: Bool = false // 최초 진입 시 한 번만 자동 위치 설정 여부
    @Published var shouldTrackUserLocation: Bool = true // 사용자가 지도를 직접 조작했는지 여부 → true일 경우에만 카메라 이동 허용
    
    /// func updateFromLocation(_ location: CLLocation?) : CLLocation 객체가 전달되었을 때, 안전하게 좌표를 추출해서 카메라 위치를 업데이트 함
    /// 위치를 받아 지도 카메라와 중심 좌표를 설정
    func updateFromLocation(_ location: CLLocation?) {
        guard let coordinate = location?.coordinate else {
            print("location is nil")
            return
        }
        print("Updating map to coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        currentMapCenter = coordinate
        cameraPosition = .region(MKCoordinateRegion(center: coordinate,
                                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
    
    func KaKaoMap(lat: Double, lng: Double) {
        // URL Scheme을 사용하여 kakaomap 앱 열고 경로 생성
        guard let url = URL(string: "kakaomap://route?ep=\(lat),\(lng)&by=CAR") else { return }
        
        // kakaomap 앱의 App store URL 생성
        guard let appStoreUrl = URL(string: "itms-apps://itunes.apple.com/app/id304608425") else { return }
        
        let urlString = "kakaomap://open"
        
        //kakaomap 앱이 설치되어 있는지 확인하고 URL 열기
        if let appUrl = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(url)
            } else {
                // kakaomap 앱이 설치되어 있지 않은 경우 App Store URL 열기
                UIApplication.shared.open(appStoreUrl)
            }
        }
    }
}
