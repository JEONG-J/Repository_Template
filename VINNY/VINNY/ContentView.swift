//
//  ContentView.swift
//  VINNY
//
//  Created by 한태빈 on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var container: DIContainer
    
    @State var text: String = ""
    
    init(container: DIContainer) {
        
    }
    
    var body: some View {
        NavigationStack (path: $container.navigationRouter.destinations) {
            VStack {
                TextField("", text: $text)
                    .border(.black)
                
                Button(action: {
                    container.navigationRouter.push(to: .SearchView)
                }, label: {
                    Text("이동")
                })
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                NavigationRoutingView(destination: destination)
                    .environmentObject(container)
            }
        } //네비게이션 스택은 최상위 뷰에서 한번만 감싸면 됨
    }
}

#Preview {
    let container = DIContainer()
    ContentView(container: container)
        .environmentObject(container)
}
