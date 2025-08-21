//
//  AppleAuthService.swift
//  VINNY
//
//  Created by 홍지우 on 8/19/25.
//

import Foundation
import AuthenticationServices

final class AppleAuthService: NSObject {
    static let shared = AppleAuthService()
    
    func signIn() async throws -> (authorizationCode: String, identityToken: String) {
        try await withCheckedThrowingContinuation { cont in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = Delegate { result in
                switch result {
                case .success(let (code, idToken)):
                    cont.resume(returning: (authorizationCode: code, identityToken: idToken)) // 라벨 붙여서 반환
                case .failure(let err):
                    cont.resume(throwing: err)
                }
            }
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            
            //Delegate를 유지(ARC 방지)
            objc_setAssociatedObject(controller, Unmanaged.passUnretained(controller).toOpaque(), delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            controller.performRequests()
        }
    }
    
    private final class Delegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        private let completion: (Result<(String, String), Error>) -> Void
        init(completion: @escaping (Result<(String, String), Error>) -> Void) { self.completion = completion }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // 적절한 윈도우 반환
            return UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first ?? ASPresentationAnchor()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let codeData = credential.authorizationCode,
                  let idTokenData = credential.identityToken,
                  let code = String(data: codeData, encoding: .utf8),
                  let idToken = String(data: idTokenData, encoding: .utf8)
            else {
                completion(.failure(NSError(domain: "AppleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 변환 실패"])))
                return
            }
            completion(.success((code, idToken)))
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            completion(.failure(error))
        }
    }
}
