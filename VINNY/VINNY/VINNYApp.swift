//
//  VINNYApp.swift
//  VINNY
//
//  Created by 한태빈 on 6/25/25.
//

import SwiftUI

@main
struct VINNYApp: App {
    @State var container: DIContainer = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            //ContentView(container: container)
            // .environmentObject(container)
            LoginView(container: container)
                .environmentObject(container)
        }
    }
}
