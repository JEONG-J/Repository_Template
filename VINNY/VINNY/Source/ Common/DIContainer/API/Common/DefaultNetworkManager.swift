//
//  DefaultNetworkManager.swift
//  VINNY
//
//  Created by 소민준 on 8/7/25.
//


// DefaultNetworkManager.swift

/*import Foundation
import Moya

final class DefaultNetworkManager<Target: TargetType> {
    let provider: MoyaProvider<Target>

    init(stub: Bool = false) {
        if stub {
            self.provider = MoyaProvider<Target>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            self.provider = MoyaProvider<Target>()
        }
    }

    func request<T: Decodable>(
        _ target: Target,
        type: T.Type
    ) async throws -> T {
        let response = try await provider.request(target)
        return try JSONDecoder().decode(T.self, from: response.data)
    }
}
*/
