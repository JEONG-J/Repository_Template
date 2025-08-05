//
//  ResetBottomView.swift
//  VINNY
//
//  Created by 한태빈 on 7/31/25.
//

import SwiftUI

struct ResetBottomView: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        VStack{

            Button(action: action) {
                Text(title)
                    .font(.suit(.medium, size: 16))
                    .foregroundStyle(isEnabled ? Color("ContentInverted") : Color("ContentBase"))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(isEnabled ? Color("BackFillInverted") : Color("BackFillRegular"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .disabled(!isEnabled)
        }
        .background(Color("BackFillRegular"))
    }
}
