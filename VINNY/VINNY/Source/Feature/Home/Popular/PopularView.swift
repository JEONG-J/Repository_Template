//
//  PopularView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct PopularView: View {
    @EnvironmentObject var container: DIContainer
        
    init(container: DIContainer) {
        
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("인기 게시글")
                    .font(.suit(.bold, size: 20))
                    .foregroundStyle(Color.contentBase)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
            }
            .padding(.top, 4)
            
            ForEach(1..<10, id: \.self) { post in
                PostCardView(container: container)
                    .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    PopularView(container: container)
        .environmentObject(container)
}
