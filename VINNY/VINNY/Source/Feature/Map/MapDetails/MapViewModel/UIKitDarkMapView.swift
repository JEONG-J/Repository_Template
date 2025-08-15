//
//  UIKitDarkMapView.swift
//  VINNY
//
//  Created by 홍지우 on 7/19/25.
//

import SwiftUI
import MapKit

/// UIKit 기반 MKMapView를 SwiftUI에서 사용하기 위한 래퍼 뷰
/// - Note: 커스텀 마커, 선택 이벤트, 카메라 추적 로직 포함
struct UIKitDarkMapView: UIViewRepresentable {
    // MARK: - Dependencies
    @StateObject var viewModel: MapViewModel
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView() // MKMapView 인스턴스를 생성.
        mapView.overrideUserInterfaceStyle = .dark // 맵 뷰에 다크 모드를 강제로 적용
        // FIXME: 라이트/다크 강제는 디자인 정책에 맞춰 외부에서 결정하도록 변경 고려 (prop로 주입)
        mapView.showsUserLocation = true // 지도에 현재 디바이스의 위치(파란 점)를 보여주도록 설정.(위치 권한이 허용 시 표시)
        mapView.delegate = context.coordinator // 맵의 델리게이트를 설정.
        
        context.coordinator.mapView = mapView
        
        // 카메라 초기 위치 설정
        if let center = viewModel.currentMapCenter {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
        
        // 마커 추가
        addMarkers(to: mapView)
        
        return mapView
    }
    
    /// 사용자 조작 중이면 카메라 강제 이동 금지
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if viewModel.shouldTrackUserLocation,
           let center = viewModel.currentMapCenter {
                let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
                uiView.setRegion(region, animated: true)
                // TODO: 과도한 setRegion 호출을 막기 위해 디바운스 적용
        }
        
        // makers 변경 반영: 사용자 위치 빼고 다 교체
        let nonUser = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(nonUser)
        
        for marker in viewModel.makers {
            uiView.addAnnotation(ShopAnnotation(marker: marker))
        }
    }

    // MARK: - Annotation
    private func addMarkers(to mapView: MKMapView) {
        for marker in viewModel.makers {
            mapView.addAnnotation(ShopAnnotation(marker: marker))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: viewModel)
    }

    /// shopId를 포함한 커스텀 어노테이션 (좌표 매칭 대신 id 기반 매칭)
    final class ShopAnnotation: MKPointAnnotation {
        let shopId: Int
        init(marker: Marker) {
            self.shopId = marker.shopId
            super.init()
            self.coordinate = marker.coordinate
            self.title = marker.title
        }
    }
    
    // MARK: - MKMapViewDelegate
    // marker 또는 커스텀 annotation 처리
    class Coordinator: NSObject, MKMapViewDelegate {
        // MARK: Properties
        var viewModel: MapViewModel
        weak var mapView: MKMapView?
        
        // MARK: Init
        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
            super.init()
            
            NotificationCenter.default.addObserver(forName: .deselectMarkerAndRefresh, object: nil, queue: .main) { [weak self] notification in
                if let marker = notification.object as? Marker {
                    self?.refreshMarker(marker)
                }
            }
        }
        
        /// 선택 해제 시 해당 마커만 새로 그림
        func refreshMarker(_ marker: Marker) {
            guard let mapView = mapView else { return }
            
            // 기존 annotation 찾아서 교체
            if let annotation = mapView.annotations.first(where: {
                $0.coordinate.latitude == marker.coordinate.latitude &&
                $0.coordinate.longitude == marker.coordinate.longitude
            }) {
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)
            }
            // TODO: 좌표 비교 대신 shopId를 annotation에 저장해 직접 비교하도록 통일 (일부는 이미 적용됨)
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // 사용자가 직접 지도 이동 시작 → 자동 추적 해제
            DispatchQueue.main.async {
                self.viewModel.shouldTrackUserLocation = false
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let shopAnno = view.annotation as? ShopAnnotation else { return }

            // makers에서 해당 마커 찾기
            guard let matched = viewModel.makers.first(where: { $0.shopId == shopAnno.shopId }) else { return }

            DispatchQueue.main.async {
                print("Marker selected: \(matched.title)")
                self.viewModel.selectedMarker = matched
                self.viewModel.selectedShopDetail = nil

                // 상세 API 호출
                self.viewModel.fetchShopDetail(shopId: matched.shopId) { detail in
                    print("✅ detail loaded: \(detail.name)")
                    // 시트 열기/갱신은 SwiftUI 쪽에서 selectedShopDetail 바인딩으로 처리
                }

                // 선택 상태 리렌더링
                mapView.removeAnnotation(shopAnno)
                mapView.addAnnotation(shopAnno)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "CustomMarker"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.annotation = annotation

            guard
                let shopAnno = annotation as? ShopAnnotation,
                let matched = viewModel.makers.first(where: { $0.shopId == shopAnno.shopId })
            else { return nil }

            // TODO: 재사용성 개선을 위해 스냅샷 이미지를 캐싱 (사이즈 동일하니 키는 shopId + isSelected)
            let isSelected = viewModel.selectedMarker?.id == matched.id
            let hosting = UIHostingController(
                rootView: LocationMapAnnotationView(category: matched.category, isSelected: isSelected)
            )
            hosting.view.backgroundColor = .clear

            let size = hosting.view.intrinsicContentSize
            hosting.view.bounds = CGRect(origin: .zero, size: size)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { _ in
                hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
            }
            annotationView.image = image
            annotationView.canShowCallout = false
            return annotationView
        }

    }
}

