import Foundation

protocol __REPO_PROTOCOL__ {
    func __OPERATION_ID__() async throws -> String
}

struct __REPO_IMPL__: __REPO_PROTOCOL__ {
    private let adapter: MoyaNetworkAdapter

    init(adapter: MoyaNetworkAdapter) {
        self.adapter = adapter
    }

    func __OPERATION_ID__() async throws -> String {
        let response = try await adapter.request(__API_ENUM__.__CASE_NAME__)
        let apiResponse = try JSONDecoder().decode(
            APIResponse<__RESPONSE_DTO__>.self,
            from: response.data
        )
        let dto = try apiResponse.unwrap()
        return dto.toDomain()
    }
}
