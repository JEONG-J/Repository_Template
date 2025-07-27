//
//  UIKitDarkMapView.swift
//  VINNY
//
//  Created by 홍지우 on 7/19/25.
//

import SwiftUI
import MapKit

struct UIKitDarkMapView: UIViewRepresentable {
    @StateObject var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView() // MKMapView 인스턴스를 생성.
        mapView.overrideUserInterfaceStyle = .dark // 맵 뷰에 다크 모드를 강제로 적용
        mapView.showsUserLocation = true // 지도에 현재 디바이스의 위치(파란 점)를 보여주도록 설정.(위치 권한이 허용 시 표시)
        mapView.delegate = context.coordinator // 맵의 델리게이트를 설정.
        
        // 카메라 초기 위치 설정
        if let center = viewModel.currentMapCenter {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
        
        // 마커 추가
        addMarkers(to: mapView)
        
        return mapView
    }
    
    // 사용자 조작 중이면 지도 강제 이동 막기
    // 사용자가 조작 중이 아니라면 지도 카메라 이동
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if viewModel.shouldTrackUserLocation,
           let center = viewModel.currentMapCenter {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        }
    }

    // 마커 추가 관리
    private func addMarkers(to mapView: MKMapView) {
        for marker in viewModel.makers {
            let annotation = MKPointAnnotation()
            annotation.coordinate = marker.coordinate
            annotation.title = marker.title
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: viewModel)
    }

    // marker 또는 커스텀 annotation 처리
    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: MapViewModel
        
        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
        }
        
        // 사용자가 지도를 움직이기 시작하면 자동 위치 추적 중단
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.viewModel.shouldTrackUserLocation = false
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }

            if let matched = viewModel.makers.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                DispatchQueue.main.async {
                    print("✅ Marker selected: \(matched.title)")
                    self.viewModel.selectedMarker = matched
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "CustomMarker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            // 해당 annotation에 맞는 Marker 찾기
            guard let matched = viewModel.makers.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) else {
                return nil
            }

            // SwiftUI View 생성
            let hosting = UIHostingController(rootView: LocationMapAnnotationView(category: matched.category))
            hosting.view.backgroundColor = .clear
            
            let targetSize = hosting.view.intrinsicContentSize
            hosting.view.bounds = CGRect(origin: .zero, size: targetSize)
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let image = renderer.image { _ in
                hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
            }
            
            annotationView?.image = image
            annotationView?.canShowCallout = false
            
            return annotationView
        }

    }
}

