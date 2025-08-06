////
////  CoursesAPITarger.swift
////  VINNY
////
////  Created by 홍지우 on 6/25/25.
////
//
//import Foundation
//import Moya
//
//enum SearchAPITarget {
//    
//    //코스 상세정보 API
//    case getCourseDetail(Request: CourseDetailRequest)
//    
//}
//
//extension SearchAPITarget: TargetType {
//    
//    
//    var headers: [String : String]? {
//        return ["Content-Type": "application/json"]
//    }
//    
//    var baseURL: URL{몌
//        return URL(string: API.searchURL)!
//    }
//    
//    var path: String {
//        switch self {
//        case .getCourseDetail:
//            return "/detail"
//        }
//    }
//    
//    var method: Moya.Method {
//        switch self {
//        case .getCourseDetail:
//            return .get
//        }
//    }
//    
//    var task: Task {
//        switch self {
//        case .getCourseDetail(let request):
//            let parameters: [String: Any] = [
//                "courseId" : request.courseId
//            ]
//            // GET인 경우(parameter)
//            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
//            
//            // POST인 경우(response body)
//            // return .requestJSONEncodable(request)
//        }
//    }
//    
//    var sampleData: Data {
//        switch self {
//        case .getCourseDetail:
//            let json = """
//                        {
//                            "isSuccess": true,
//                            "code": "123",
//                            "message": "hi",
//                            "result": {
//                                "courseId": 1,
//                                "courseImage": "https://example.com/image.jpg",
//                                "courseName": "서울 야경 투어",
//                                "courseDescription": "서울의 야경을 즐길 수 있는 코스입니다.",
//                                "courseType": "night",
//                                "rating": 5,
//                                "reviewCount": 128,
//                                "recommendTime": "2시간",
//                                "participantsNumber": 58,
//                                "isBookMarked": true,
//                                "placeInfos": [
//                                    {
//                                        "placeId": 101,
//                                        "placeName": "남산타워",
//                                        "placeLatitude": 37.5512,
//                                        "placeLongitude": 126.9882,
//                                        "isVisited": true
//                                    },
//                                    {
//                                        "placeId": 102,
//                                        "placeName": "한강공원",
//                                        "placeLatitude": 37.5172,
//                                        "placeLongitude": 126.9368,
//                                        "isVisited": false
//                                    }
//                                ]
//                            }
//                        }
//                        """
//                        return Data(json.utf8)
//        }
//    }
//}
//
//
