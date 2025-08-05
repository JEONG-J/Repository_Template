//
//  FileDetails.swift
//  VINNY
//
//  Created by 홍지우 on 7/31/25.
//

import Foundation
import PhotosUI

struct FileDetails: Identifiable {
    var id: String { name }
    let name: String
    let fileType: UTType
}
