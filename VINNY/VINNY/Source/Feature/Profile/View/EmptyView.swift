//
//  EmptyView.swift
//  VINNY
//
//  Created by 한태빈 on 8/12/25.
//

import SwiftUI
struct EmptyView: View {
    var body: some View {
        ZStack {
            Color("BackRootRegular").ignoresSafeArea() // 배경색
            VStack(alignment: .center, spacing: 10){
                Image("noneImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.horizontal, 10)
                Text("표시할 내용이 없어요!")
                    .font(.suit(.regular, size: 16))
                    .foregroundStyle(Color.contentAssistive)
                    .padding(.horizontal, 10)
            }
        }
        .frame(minHeight: 295)
    }
}

#Preview {
    EmptyView()
}
