import Testing
@testable import AppName

private struct Mock__REPO_PROTOCOL__: __REPO_PROTOCOL__ {
    var result: Result<String, Error> = .success("ok")

    func __OPERATION_ID__() async throws -> String {
        try result.get()
    }
}

@Suite("__OPERATION_PASCAL__ UseCase")
struct __OPERATION_PASCAL__UseCaseTests {
    @Test("성공 시 값 반환")
    func executeSuccess() async throws {
        let repo = Mock__REPO_PROTOCOL__(result: .success("ok"))
        let sut = __USECASE_IMPL__(repository: repo)
        let value = try await sut.execute()
        #expect(value == "ok")
    }
}
