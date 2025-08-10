//
//  OnboardResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/9/25.
//

import Foundation

struct OnboardResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String?
    let timestamp: String
}
