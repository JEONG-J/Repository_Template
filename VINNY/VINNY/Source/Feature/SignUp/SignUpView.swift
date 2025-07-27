//
//  SignUpView\.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let container = DIContainer()
    SignUpView(container: container)
        .environmentObject(container)
}
