//
//  Marker.swift
//  VINNY
//
//  Created by 홍지우 on 7/15/25.
//

import Foundation
import MapKit

struct Marker: Identifiable, Equatable {
    let id = UUID()
    let shopId: Int
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
