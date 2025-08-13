//
//  UploadReviewViewModel.swift
//  VINNY
//
//  Created by 한태빈 on 8/14/25.
//


import Foundation
import PhotosUI

final class UploadReviewViewModel: ObservableObject {
    @Published var postImages: [UIImage] = [] // 실제 업로드할 이미지 배열
    @Published var currentIndex: Int = 0 // 이미지 페이지 뷰의 현재 인덱스
    
    @Published var title: String = "" // 제목
    @Published var content: String = "" // 내용
    var selectedImageCount: Int {
        postImages.count
    }
    
    func addImage(_ image: UIImage) {
        if postImages.count < 5 {
            postImages.append(image)
        }
    }
    
    func resetImages() {
        postImages = []
    }
}
