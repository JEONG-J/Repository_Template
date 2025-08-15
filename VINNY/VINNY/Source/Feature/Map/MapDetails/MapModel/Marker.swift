//
//  Marker.swift
//  VINNY
//
//  Created by 홍지우 on 7/15/25.
//

import Foundation
import MapKit

/// 지도에 표시되는 단일 샵 정보(좌표/타이틀/카테고리)
struct Marker: Identifiable, Equatable {
    // MARK: Identity
    let id = UUID()
    let shopId: Int
    
    // MARK: Geometry & Display
    let coordinate: CLLocationCoordinate2D
    let title: String
    let category: Category
    
    static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.category == rhs.category &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
