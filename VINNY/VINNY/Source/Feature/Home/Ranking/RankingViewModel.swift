//
//  RankingViewModel.swift
//  VINNY
//
//  Created by 소민준 on 8/17/25.
//

import SwiftUI

final class RankingViewModel: ObservableObject {
    @Published var shops: [ShopByRankingDTO] = []
    
    func getRanking(region: [String]?, style: [String]?) async {
        do {
            let shops = try await ShopAPITarget.getRanking(
                page: 0,
                size: 20,
                region: region,  // ⬅ 파라미터 쓰기
                style: style
            )
            DispatchQueue.main.async {
                self.shops = shops
            }
        } catch {
            print("Error:", error)
        }
    }
}
