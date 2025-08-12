//
//  File.swift
//  VINNY
//
//  Created by 한태빈 on 8/12/25.
//
import Foundation

struct NotificationItem: Identifiable, Hashable {
    let id = UUID()
    var userName: String
    var message: String
    var minutesAgo: Int
    var isNew: Bool
    var thumbnailName: String? = nil
}
