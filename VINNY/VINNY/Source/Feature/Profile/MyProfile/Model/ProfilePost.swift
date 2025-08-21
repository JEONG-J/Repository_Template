//
//  ProfilePostModel.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import Foundation

struct ProfilePost: Identifiable, Equatable {
    let id: UUID
    let imageName: String
    var isSaved: Bool
}
