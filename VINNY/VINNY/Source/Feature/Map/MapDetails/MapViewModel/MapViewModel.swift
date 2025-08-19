//
//  MapViewModel.swift
//  VINNY
//
//  Created by 홍지우 on 7/12/25.
//

import SwiftUI
import MapKit
import Observation
import KakaoMapsSDK
import Moya

/// 지도 화면의 상태/사이드 이펙트(네트워크, 위치 업데이트)를 관리
final class MapViewModel: ObservableObject {
    // MARK: - Dependencies
    private let mapProvider = MoyaProvider<MapAPITarget>()
    
    // MARK: - Camera & Center
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic) // 지도 카메라 위치. 기본은 사용자 위치
    @Published var currentMapCenter: CLLocationCoordinate2D? // 현재 지도의 중심 좌표 (내 위치 중심 or 마커 위치 등)
    
    // MARK: - Map Data
    @Published var makers: [Marker] = []
    @Published var selectedMarker: Marker? // 사용자가 선택한 마커 → 바텀 시트로 노출됨
    @Published var selectedShopDetail: GetShopOnMapDTO? = nil // 상세 상태 보관
    
    // MARK: - Flags
    @Published var hasSetInitialRegion: Bool = false // 최초 진입 시 한 번만 자동 위치 설정 여부
    @Published var shouldTrackUserLocation: Bool = true // 사용자가 지도를 직접 조작했는지 여부 → true일 경우에만 카메라 이동 허용
    
    // MARK: - Saved Shops
    @Published var showingFavorites: Bool = false
    
    // MARK: - Location
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
    
    // MARK: - External Apps
    /// 카카오맵으로 길찾기
    // TODO: 외부 라우팅은 별도 Router로 분리 (ViewModel 책임 축소)
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
    
    // MARK: - APIs
    /// 전체 가게 목록 조회 → Marker 변환
    func fetchShops() {
        mapProvider.request(.getAllShop) { (result: Result<Response, MoyaError>) in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else { return }
                do {
                    let decoded = try JSONDecoder().decode(MapAllResponseDTO.self, from: response.data)

                    let markers = decoded.result.map { item in
                        let primaryName = item.mainVintageStyle?.vintageStyleName ?? item.vintageStyleList.first?.vintageStyleName
                        return Marker(
                            shopId: item.id,
                            coordinate: .init(latitude: item.latitude, longitude: item.longitude),
                            title: "Shop #\(item.id)",
                            category: Category.fromAPI(primaryName)
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.makers = markers
                    }
                } catch {
                    print("❌ JSON Decode Error:", error)
                    print("↳ raw body:", String(data: response.data, encoding: .utf8) ?? "binary")
                }
            case .failure(let error):
                print("❌ API Error:", error)
            }
        }
    }
    
    /// 마커 선택 시 상세 조회
    func fetchShopDetail(shopId: Int, completion: ((GetShopOnMapDTO) -> Void)? = nil) {
        mapProvider.request(.getShopOnMap(shopId: shopId)) { (result: Result<Response, MoyaError>) in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    print("❌ HTTP \(response.statusCode)")
                    print("↳ body:", String(data: response.data, encoding: .utf8) ?? "no body")
                    return
                }
                do {
                    let dto = try JSONDecoder().decode(
                        MapEnvelope<GetShopOnMapDTO>.self,
                        from: response.data
                    ).result
                    
                    DispatchQueue.main.async {
                        if self.selectedMarker?.shopId == dto.id {
                            self.selectedShopDetail = dto         // 상세 저장
                        }
                    }
                } catch {
                    print("❌ Decode detail error:", error)
                    print("↳ raw:", String(data: response.data, encoding: .utf8) ?? "binary")
                }
            case .failure(let err):
                print("❌ API error:", err)
            }
        }
    }
    
    func fetchSavedShops() {
        mapProvider.request(.getSavedShopOnMap) { (result: Result<Response, MoyaError>) in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    print("❌ HTTP \(response.statusCode) for favorites")
                    print("↳ body:", String(data: response.data, encoding: .utf8) ?? "no body")
                    return
                }
                do {
                    // 서버 스펙: envelope 안에 [GetSavedShopDTO]
                    let saved = try JSONDecoder()
                        .decode(MapEnvelope<[GetSavedShopDTO]>.self, from: response.data)
                        .result

                    let markers = saved.map { item in
                        let primaryName = item.mainVintageStyle?.vintageStyleName ?? item.vintageStyleList.first?.vintageStyleName
                        return Marker(
                            shopId: item.id,
                            coordinate: .init(latitude: item.latitude, longitude: item.longitude),
                            title: "Shop #\(item.id)",
                            category: Category.fromAPI(primaryName)
                        )
                    }

                    DispatchQueue.main.async {
                        self.makers = markers
                    }
                } catch {
                    print("❌ Decode favorites error:", error)
                    print("↳ raw:", String(data: response.data, encoding: .utf8) ?? "binary")
                    // 실패 시 전부 즐겨찾기로 보이지 않도록 기존 makers 유지 or 비우는 쪽 택1
                    // self.makers = []
                }

            case .failure(let err):
                print("❌ API error (favorites):", err)
            }
        }
    }

    
    // ★ 버튼 토글 시 호출
    func toggleFavorites() {
        showingFavorites.toggle()
        if showingFavorites {
            fetchSavedShops()
        } else {
            fetchShops() // 전체 목록으로 복귀
        }
    }
}
