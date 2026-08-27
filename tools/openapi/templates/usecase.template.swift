import Foundation

protocol __USECASE_PROTOCOL__ {
    func execute() async throws -> String
}

final class __USECASE_IMPL__: __USECASE_PROTOCOL__ {
    private let repository: __REPO_PROTOCOL__

    init(repository: __REPO_PROTOCOL__) {
        self.repository = repository
    }

    func execute() async throws -> String {
        try await repository.__OPERATION_ID__()
    }
}
