//
//  AuthRequestDTO.swift
//  VINNY
//
//  Created by 소민준 on 8/6/25.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let accessToken: String
}

struct ReissueTokenRequestDTO: Encodable {
    let refreshToken: String
}
