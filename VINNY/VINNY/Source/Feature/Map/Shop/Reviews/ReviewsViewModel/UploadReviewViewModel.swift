//
//  UploadReviewViewModel.swift
//  VINNY
//
//  Created by 한태빈 on 8/14/25.
//


import Foundation
import PhotosUI
import Moya

final class UploadReviewViewModel: ObservableObject {
    
    @Published var title: String = "" // 제목
    @Published var content: String = "" // 내용
    @Published var postImages: [UIImage] = [] // 실제 업로드할 이미지 배열
    @Published var currentIndex: Int = 0 // 이미지 페이지 뷰의 현재 인덱스
    
    @Published var isUploading = false
    @Published var uploadError: String?
    
    private let provider = MoyaProvider<ShopsAPITarget>()
    
    var selectedImageCount: Int {
        postImages.count
    }
    
    func addImage(_ image: UIImage) {
        if postImages.count < 2 {
            postImages.append(image)
        }
    }
    
    func resetImages() {
        postImages = []
    }
    
    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func upload(shopId: Int, completion: @escaping (ShopReview?) -> Void) {
        isUploading = true
        uploadError = nil
        
        let datas = postImages.compactMap{ $0.jpegData(compressionQuality: 0.85)}
        let dto = ReviewCreateDTO(title: title, content: content)
        
        provider.request(.postShopReview(shopId: shopId, dto: dto, images: datas)) { [weak self] result in
            guard let self else { return }
            self.isUploading = false
            
            switch result {
            case .success(let res):
                guard (200...299).contains(res.statusCode) else {
                    self.uploadError = "HTTP \(res.statusCode): " + (String(data: res.data, encoding: .utf8) ?? "")
                    completion(nil)
                    return
                }
                // POST 응답은 단일 객체
                do {
                    let review = try JSONDecoder().decode(ShopReview.self, from: res.data)
                    completion(review)
                } catch {
                    self.uploadError = "디코딩 실패: \(error.localizedDescription)"
                    completion(nil)
                }
                
            case .failure(let err):
                self.uploadError = err.localizedDescription
                completion(nil)
            }
        }
    }
}
