//
//  DIContainer.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import SwiftUI
import Combine

class DIContainer: ObservableObject {
    var navigationRouter: NavigationRoutable
    
    var useCaseProvider: UseCaseProvider
    @Published var onboardingSelection = OnboardingSelection()
    @Published var editingPostId: Int? = nil
    
    
    init() {
        self.navigationRouter = NavigationRouter()
        self.useCaseProvider = UseCaseProvider()
        
    }
    
}
