//
//  LocationManager.swift
//  VINNY
//
//  Created by 홍지우 on 7/11/25.
//

/// LocationManager는 디바이스의 GPS와 직접 통신해서 위치를 받아오는 객체(위치 추적 기능만 담당)
/// CLLocationManager 은 코드 길고 복잡.
import Foundation
import CoreLocation
import MapKit
import Observation

@Observable
class LocationManager: NSObject{
    static let shared = LocationManager()
    
    // MARK: - CLLocationManager
    private let locationManager = CLLocationManager()
    
    // MARK: - Published Properties
    var currentLocation: CLLocation? = nil
    var onLocationUpdate: ((CLLocation?) -> Void)?
    var currentHeading: CLHeading?
   
    var currentSpeed: CLLocationSpeed = 0
    var currentDirection: CLLocationDirection = 0
   
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
   
    var didEnterGeofence: Bool = false
    
    // MARK: - Init
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = kCLHeadingFilterNone
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
//        startUpdatingLocation()
        requestAuthorization()
        startUpdatingHeading()
        print("LocationManager 초기화됨")
    }
    
    // MARK: - 권한 요청
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - 위치 추적
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - 방향 추적
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }

    // MARK: - Significant Location Change
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: - 방문 감지
    func startMonitoringVisits() {
        locationManager.startMonitoringVisits()
    }
    
    // MARK: - 지오펜싱
    func startMonitoringGeofence(center: CLLocationCoordinate2D,
                                 radius: CLLocationDistance,
                                 identifier: String) {
        let region = CLCircularRegion(center: center,
                                      radius: radius,
                                      identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
    }

    func stopMonitoringAllGeofences() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    // 권한 변경 감지
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    // 위치 업데이트 감지 (기본 위치 추적 + Significant Change)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latest = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = latest
                self.currentSpeed = max(latest.speed, 0)
            }
        }
    }

    // 방향 감지
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.currentHeading = newHeading
            self.currentDirection = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
    }

    // 방문 감지 (visit monitoring)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("방문 감지됨 - 좌표: \(visit.coordinate), 도착: \(visit.arrivalDate), 출발: \(visit.departureDate)")
    }

    // 지오펜싱: 진입
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        DispatchQueue.main.async {
            self.didEnterGeofence = true
        }
    }

    // 지오펜싱: 이탈
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        DispatchQueue.main.async {
            self.didEnterGeofence = false
        }
    }

    // 오류 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류: \(error.localizedDescription)")
    }
}
