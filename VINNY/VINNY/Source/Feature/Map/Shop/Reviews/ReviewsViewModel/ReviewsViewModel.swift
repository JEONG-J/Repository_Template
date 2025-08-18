//
//  ReviewsViewModel.swift
//  VINNY
//
//  Created by 홍지우 on 8/18/25.
//

import Foundation
import Moya

@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [ShopReview] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let provider = MoyaProvider<ShopsAPITarget>()
    
    func load(shopId: Int) async {
        isLoading = true
        errorMessage = nil
        
        provider.request(.getShopReview(shopId: shopId)) { [weak self] (result: Result<Response, MoyaError>) in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    self.errorMessage = "HTTP \(response.statusCode)"
                    print("↳ body:", String(data: response.data, encoding: .utf8) ?? "no body")
                    return
                }
                do {
                    let env = try JSONDecoder().decode(ReviewEnvelope<[ShopReview]>.self, from: response.data)
                    guard env.isSuccess else {
                        self.errorMessage = env.message
                        return
                    }
                    self.reviews = env.result
                } catch let DecodingError.keyNotFound(key, ctx) {
                    self.errorMessage = "키 누락: \(key.stringValue) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: "."))"
                } catch let DecodingError.typeMismatch(type, ctx) {
                    self.errorMessage = "타입 불일치: \(type) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: "."))"
                } catch let DecodingError.valueNotFound(value, ctx) {
                    self.errorMessage = "값 누락: \(value) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: "."))"
                } catch let DecodingError.dataCorrupted(ctx) {
                    self.errorMessage = "데이터 손상: \(ctx.debugDescription)"
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }
}
