//
//  PostUploadViewModel.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import Foundation

final class PostUploadViewModel: ObservableObject {
    @Published var title: String = "" // 제목
    @Published var content: String = "" // 내용
    @Published var styles: [String] = []
    @Published var brand: String = "" // 브랜드 입력
    @Published var shoptag: String = "" // 스타일 선택
}
