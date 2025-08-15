////  네트워크 요청을 담당하는 공통 관리 객체.
////  - Moya 기반으로 네트워크 추상화를 제공함
////  - 각 Feature에서 API enum을 정의하고, 해당 enum 타입으로 제네릭 네트워크 요청 가능
//
//import Foundation
//import Moya
//
//// MARK: - 프로토콜 정의
//
///// Moya의 TargetType을 기반으로 다양한 API 요청을 처리하기 위한 공통 인터페이스.
///// SwiftUI에서도 각 ViewModel이 이 프로토콜을 통해 네트워크 요청을 보냄.
//protocol NetworkManager {
//    associatedtype Endpoint: TargetType
//    var provider: MoyaProvider<Endpoint> { get }
//
//    /// 일반적인 응답이 있는 API 요청
//    func request<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
//
//    /// 응답이 Optional인 경우 (데이터가 없을 수도 있음)
//    func requestOptional<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T?, NetworkError>) -> Void)
//
//    /// 응답 데이터 없이 상태 코드로만 성공 여부 판단 (204, 200 등)
//    func requestStatusCode(target: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void)
//
//    /// 응답 + Cache-Control max-age 정보까지 함께 반환하는 요청
//    func requestWithTime<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void)
//}
//
//// MARK: - 구현체
//
///// NetworkManager 프로토콜을 실제로 구현한 기본 네트워크 매니저.
///// ViewModel에서 `DefaultNetworkManager<SomeAPI>()` 형태로 사용.
//final class DefaultNetworkManager<API: TargetType>: NetworkManager {
//    typealias Endpoint = API
//    let provider: MoyaProvider<API>
//
//    /// 테스트(stub) 여부에 따라 실제 네트워크 or 즉시 응답 선택 가능
//    init(stub: Bool = false) {
//        if stub {
//            provider = MoyaProvider<API>(stubClosure: MoyaProvider.delayedStub(0.5))
//        } else {
//            provider = MoyaProvider<API>()
//        }
//    }
//
//    // MARK: - 실제 요청 함수 구현
//
//    func request<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
//        provider.request(target) { [self] result in
//            switch result {
//            case .success(let response):
//                let decoded = handleResponse(response, decodingType: decodingType)
//                completion(decoded)
//            case .failure(let error):
//                completion(.failure(handleNetworkError(error)))
//            }
//        }
//    }
//
//    func requestOptional<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T?, NetworkError>) -> Void) {
//        provider.request(target) { [self] result in
//            switch result {
//            case .success(let response):
//                do {
//                    guard (200...299).contains(response.statusCode) else {
//                        let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
//                        return completion(.failure(.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류")))
//                    }
//
//                    if response.data.isEmpty {
//                        return completion(.success(nil))
//                    }
//
//                    let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
//                    return completion(.success(apiResponse.result))
//
//                } catch {
//                    return completion(.failure(.decodingError(underlyingError: error as! DecodingError)))
//                }
//
//            case .failure(let error):
//                completion(.failure(handleNetworkError(error)))
//            }
//        }
//    }
//
//    func requestStatusCode(target: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void) {
//        provider.request(target) { [self] result in
//            switch result {
//            case .success(let response):
//                if (200...299).contains(response.statusCode) {
//                    completion(.success(()))
//                } else {
//                    let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
//                    completion(.failure(.serverError(statusCode: response.statusCode, message: error?.message ?? "상태 코드 오류")))
//                }
//            case .failure(let error):
//                completion(.failure(handleNetworkError(error)))
//            }
//        }
//    }
//
//    func requestWithTime<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void) {
//        provider.request(target) { [self] result in
//            switch result {
//            case .success(let response):
//                do {
//                    guard (200...299).contains(response.statusCode) else {
//                        let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
//                        return completion(.failure(.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류")))
//                    }
//
//                    let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
//                    guard let result = apiResponse.result else {
//                        return completion(.failure(.serverError(statusCode: response.statusCode, message: "결과 없음")))
//                    }
//
//                    let cacheTime = extractCacheTimeInterval(from: response)
//                    completion(.success((result, cacheTime)))
//
//                } catch {
//                    completion(.failure(.decodingError(underlyingError: error as! DecodingError)))
//                }
//            case .failure(let error):
//                completion(.failure(handleNetworkError(error)))
//            }
//        }
//    }
//
//    // MARK: - 내부 유틸리티 함수
//
//    /// 공통 응답 처리 로직 (성공/실패/디코딩)
//    private func handleResponse<T: Decodable>(_ response: Response, decodingType: T.Type) -> Result<T, NetworkError> {
//        do {
//            guard (200...299).contains(response.statusCode) else {
//                let error = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
//                return .failure(.serverError(statusCode: response.statusCode, message: error?.message ?? "서버 오류"))
//            }
//
//            // ✅ LoginResponseDTO는 별도로 처리
//            if T.self == LoginResponseDTO.self {
//                let loginResponse = try JSONDecoder().decode(LoginResponseDTO.self, from: response.data)
//                return .success(loginResponse as! T)
//            }
//
//            // ✅ 그 외는 기존처럼 ApiResponse<T>로 디코딩
//            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
//            guard let result = apiResponse.result else {
//                return .failure(.serverError(statusCode: response.statusCode, message: "결과 없음"))
//            }
//
//            return .success(result)
//
//        } catch {
//            print("디코딩 실패: \(error)")
//            if let raw = String(data: response.data, encoding: .utf8) {
//                print("서버 응답 원문:\n\(raw)")
//            }
//
//            return .failure(.decodingError(underlyingError: error as! DecodingError))
//        }
//    }
//
//    /// Moya에서 받은 네트워크 에러를 우리 서비스용 에러로 변환
//    private func handleNetworkError(_ error: Error) -> NetworkError {
//        let nsError = error as NSError
//        switch nsError.code {
//        case NSURLErrorNotConnectedToInternet:
//            return .networkError(message: "인터넷 연결 없음")
//        case NSURLErrorTimedOut:
//            return .networkError(message: "요청 시간 초과")
//        default:
//            return .networkError(message: "알 수 없는 네트워크 오류")
//        }
//    }
//
//    /// Cache-Control max-age 파싱 함수 (requestWithTime에서 사용)
//    private func extractCacheTimeInterval(from response: Response) -> TimeInterval? {
//        guard let cacheControl = response.response?.allHeaderFields["Cache-Control"] as? String else { return nil }
//        let components = cacheControl.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
//        for component in components {
//            if component.starts(with: "max-age") {
//                if let value = component.split(separator: "=").last, let interval = TimeInterval(value) {
//                    return interval
//                }
//            }
//        }
//        return nil
//    }
//}
//
//
