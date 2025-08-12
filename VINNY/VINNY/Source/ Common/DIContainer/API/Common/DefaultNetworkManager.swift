import Foundation
import Moya

public final class DefaultNetworkManager<T: TargetType> {

    private let provider: MoyaProvider<T>

    // 네 프로젝트의 NetworkError에 맞추기 위한 매핑 클로저들
    private let mapNetwork: (Error) -> NetworkError
    private let mapHttp: (Int, Data?) -> NetworkError
    private let mapDecoding: (Error) -> NetworkError
    private let mapAPI: (String, String) -> NetworkError

    public init(
        stub: Bool = false,
        plugins: [PluginType] = [],
        session: Session? = nil,
        mapNetwork: @escaping (Error) -> NetworkError,
        mapHttp: @escaping (Int, Data?) -> NetworkError,
        mapDecoding: @escaping (Error) -> NetworkError,
        mapAPI: @escaping (String, String) -> NetworkError
    ) {
        self.mapNetwork = mapNetwork
        self.mapHttp = mapHttp
        self.mapDecoding = mapDecoding
        self.mapAPI = mapAPI

        let stubClosure: MoyaProvider<T>.StubClosure = { _ in stub ? .immediate : .never }

        var defaultPlugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]

        self.provider = MoyaProvider<T>(
            stubClosure: stubClosure,
            session: session ?? DefaultNetworkManager.makeDefaultSession(),
            plugins: defaultPlugins + plugins
        )
    }

    /// 네 NetworkError가 `.network/.http/.decoding/.api`처럼 이미 구성돼 있다면 이 생성자를 써도 됨
    public convenience init(
        stub: Bool = false,
        plugins: [PluginType] = [],
        session: Session? = nil
    ) {
        self.init(
            stub: stub,
            plugins: plugins,
            session: session,
            mapNetwork: { .networkError(message: $0.localizedDescription) },
            mapHttp: { status, data in
                let msg = String(data: data ?? Data(), encoding: .utf8) ?? ""
                return .serverError(statusCode: status, message: msg)
            },
            mapDecoding: { err in
                if let de = err as? DecodingError { return .decodingError(underlyingError: de) }
                return .decodingError(underlyingError: DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: err.localizedDescription)))
            },
            mapAPI: { message, code in
                // 서버 isSuccess=false일 때
                return .serverError(statusCode: -1, message: "[\(code)] \(message)")
            }
        )
    }

    // MARK: - R로 직접 디코딩 (Completion)
    public func request<R: Decodable>(
        target: T,
        decodingType: R.Type,
        completion: @escaping (Result<R, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let ok = try response.filterSuccessfulStatusCodes()
                    let dto = try JSONDecoder.vinny.decode(R.self, from: ok.data)
                    completion(.success(dto))
                } catch let moya as MoyaError {
                    completion(.failure(self.mapHttp(moya.response?.statusCode ?? -1, moya.response?.data)))
                } catch {
                    completion(.failure(self.mapDecoding(error)))
                }
            case .failure(let err):
                completion(.failure(self.mapNetwork(err)))
            }
        }
    }

    // MARK: - R로 직접 디코딩 (Async/Await)
    public func request<R: Decodable>(
        target: T,
        decodingType: R.Type
    ) async throws -> R {
        try await withCheckedThrowingContinuation { cont in
            request(target: target, decodingType: decodingType) { result in
                cont.resume(with: result)
            }
        }
    }

    // MARK: - 공통 응답 언래핑 (이름/타입 자유, KeyPath 지정)
    public func requestUnwrap<Envelope: Decodable, R>(
        target: T,
        envelope: Envelope.Type,
        isSuccess: KeyPath<Envelope, Bool>,
        code: KeyPath<Envelope, String>,
        message: KeyPath<Envelope, String>,
        result: KeyPath<Envelope, R>,
        completion: @escaping (Result<R, NetworkError>) -> Void
    ) {
        request(target: target, decodingType: Envelope.self) { res in
            switch res {
            case .success(let env):
                if env[keyPath: isSuccess] {
                    completion(.success(env[keyPath: result]))
                } else {
                    completion(.failure(self.mapAPI(env[keyPath: message], env[keyPath: code])))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 공통 응답 언래핑 (Async/Await)
    public func requestUnwrap<Envelope: Decodable, R>(
        target: T,
        envelope: Envelope.Type,
        isSuccess: KeyPath<Envelope, Bool>,
        code: KeyPath<Envelope, String>,
        message: KeyPath<Envelope, String>,
        result: KeyPath<Envelope, R>
    ) async throws -> R {
        try await withCheckedThrowingContinuation { cont in
            requestUnwrap(
                target: target, envelope: envelope,
                isSuccess: isSuccess, code: code, message: message, result: result
            ) { res in
                cont.resume(with: res)
            }
        }
    }

    private static func makeDefaultSession() -> Session {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 40
        cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return Session(configuration: cfg)
    }
}

private extension JSONDecoder {
    static let vinny: JSONDecoder = {
        let d = JSONDecoder()
        // d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
}
