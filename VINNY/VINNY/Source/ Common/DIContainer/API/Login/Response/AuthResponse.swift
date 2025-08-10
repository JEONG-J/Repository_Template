//
//  AuthResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/6/25.
//

import Foundation

struct LoginResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: LoginResult
    let timestamp: String
}

struct LoginResult: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
}

struct ReissueTokenResponseDTO: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
}

struct MeResponseDTO: Decodable {
    let result: String
}

struct SessionResponseDTO: Codable {
    let  isSuccess: Bool
    let code : String
    let message: String
    let result:SessionResultResponseDTO
    let timestamp : String
}

struct SessionResultResponseDTO: Codable {
    let status: String
    let needRefresh: Bool
}
