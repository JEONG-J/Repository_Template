import Foundation
import Moya

enum __API_ENUM__ {
    case __CASE_NAME__
}

extension __API_ENUM__: BaseTargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .__CASE_NAME__:
            return "__API_PATH__"
        }
    }

    var method: Moya.Method {
        switch self {
        case .__CASE_NAME__:
            return .__HTTP_METHOD__
        }
    }

    var task: Task {
        switch self {
        case .__CASE_NAME__:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
