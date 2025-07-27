//
//  Marker.swift
//  VINNY
//
//  Created by 홍지우 on 7/15/25.
//

import Foundation
import MapKit

struct Marker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let category: Category
}
