import Foundation

protocol UseCaseProtocol {
    
    var userUseCase: DefaultNetworkManager<UsersAPITarget> { get set }
    
    var shopUseCase: DefaultNetworkManager<ShopsAPITarget> { get set }
    
    var searchUseCase: DefaultNetworkManager<SearchAPITarget> { get set }
    
    var profileUseCase: DefaultNetworkManager<ProfileAPITarget> { get set }
    
    var postUseCase: DefaultNetworkManager<PostsAPITarget> { get set }
    //var reviewUseCase: DefaultNetworkManager<ReviewAPITarget> { get set }
    
}

class UseCaseProvider: UseCaseProtocol{
    var userUseCase: DefaultNetworkManager<UsersAPITarget>
    
    var shopUseCase: DefaultNetworkManager<ShopsAPITarget>
    
    var searchUseCase: DefaultNetworkManager<SearchAPITarget>
    
    var profileUseCase: DefaultNetworkManager<ProfileAPITarget>
    
    var postUseCase: DefaultNetworkManager<PostsAPITarget>
    
    init() {
//        courseUseCase = DefaultNetworkManager<CoursesAPITarget>(stub: true) //stub: true 적으면 더미 데이터로 가져옴
        userUseCase = DefaultNetworkManager<UsersAPITarget>()
        
        shopUseCase = DefaultNetworkManager<ShopsAPITarget>()
        
        searchUseCase = DefaultNetworkManager<SearchAPITarget>()
        
        profileUseCase = DefaultNetworkManager<ProfileAPITarget>()
        
        postUseCase = DefaultNetworkManager<PostsAPITarget>()
    }
}

