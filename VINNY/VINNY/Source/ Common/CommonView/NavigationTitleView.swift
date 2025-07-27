//
//  NavigationTitleView.swift
//  VINNY
//
//  Created by 한태빈 on 7/25/25.
//

import SwiftUI

struct NavigationTitleView: View {
    @Environment(NavigationRouter.self) var router: NavigationRouter
    let title: String

    var body: some View {
        HStack{
            Button(action: {
                router.pop()
            }) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 10, height: 18)
                    .foregroundStyle(Color("ContentBase"))
            }
            
            Spacer()
            
            Text(title)
                .font(.suit(.medium, size: 16))
                .foregroundStyle(Color("ContentBase"))
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color("BackFillRegular"))
    }
}
