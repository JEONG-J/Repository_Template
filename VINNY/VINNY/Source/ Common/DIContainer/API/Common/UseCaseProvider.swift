import Foundation
import Moya

protocol UseCaseProtocol {
    
    var userUseCase: DefaultNetworkManager<UsersAPITarget> { get set }
    
    var shopUseCase: DefaultNetworkManager<ShopsAPITarget> { get set }
    
    var searchUseCase: DefaultNetworkManager<SearchAPITarget> { get set }
    
    var mypageUseCase: DefaultNetworkManager<MypageAPITarget> { get set }
    
    var onboardUseCase: MoyaProvider<OnboardAPITarget> { get set }
    
    var authUseCase: MoyaProvider<AuthAPITarget> { get set }
    
    var postUseCase: DefaultNetworkManager<PostsAPITarget> { get set }

    var mapUseCase: DefaultNetworkManager<MapAPITarget> { get set }
}

class UseCaseProvider: UseCaseProtocol{
    var userUseCase: DefaultNetworkManager<UsersAPITarget>
    
    var shopUseCase: DefaultNetworkManager<ShopsAPITarget>
    
    var searchUseCase: DefaultNetworkManager<SearchAPITarget>
    
    var mypageUseCase: DefaultNetworkManager<MypageAPITarget>
    
    var onboardUseCase: MoyaProvider<OnboardAPITarget>
    
    var authUseCase: MoyaProvider<AuthAPITarget>
    
    var postUseCase: DefaultNetworkManager<PostsAPITarget>
    
    var mapUseCase: DefaultNetworkManager<MapAPITarget>


    init() {
        userUseCase = DefaultNetworkManager<UsersAPITarget>()
        
        shopUseCase = DefaultNetworkManager<ShopsAPITarget>()
        
        searchUseCase = DefaultNetworkManager<SearchAPITarget>()
        
        mypageUseCase = DefaultNetworkManager<MypageAPITarget>()
        
        postUseCase = DefaultNetworkManager<PostsAPITarget>()
        
        mapUseCase = DefaultNetworkManager<MapAPITarget>()
        // 공통 endpoint: 권한 필요하면 Bearer 토큰을 헤더에 주입 (타겟별 클로저)
        let authEndpointClosure: MoyaProvider<AuthAPITarget>.EndpointClosure = { target in
            let defaultEP = MoyaProvider.defaultEndpointMapping(for: target)
            var headers = defaultEP.httpHeaderFields ?? [:]

            let token = KeychainHelper.shared.get(forKey: "accessToken") ?? ""
            if
                let authorizable = target as? AccessTokenAuthorizable,
                authorizable.authorizationType == .bearer,
                !token.isEmpty
            {
                headers["Authorization"] = "Bearer \(token)"
            }
            if headers["Content-Type"] == nil {
                headers["Content-Type"] = "application/json"
            }
            return defaultEP.adding(newHTTPHeaderFields: headers)
        }

        let onboardEndpointClosure: MoyaProvider<OnboardAPITarget>.EndpointClosure = { target in
            let defaultEP = MoyaProvider.defaultEndpointMapping(for: target)
            var headers = defaultEP.httpHeaderFields ?? [:]

            let token = KeychainHelper.shared.get(forKey: "accessToken") ?? ""
            if
                let authorizable = target as? AccessTokenAuthorizable,
                authorizable.authorizationType == .bearer,
                !token.isEmpty
            {
                headers["Authorization"] = "Bearer \(token)"
            }
            if headers["Content-Type"] == nil {
                headers["Content-Type"] = "application/json"
            }
            return defaultEP.adding(newHTTPHeaderFields: headers)
        }
        
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        
        self.authUseCase = MoyaProvider<AuthAPITarget>(
            endpointClosure: authEndpointClosure,
            plugins: plugins
        )
        
        self.onboardUseCase = MoyaProvider<OnboardAPITarget>(
            endpointClosure: onboardEndpointClosure,
            plugins: plugins
        )
    }
    
}
