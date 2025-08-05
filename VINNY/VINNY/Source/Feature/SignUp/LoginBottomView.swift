//
//  LoginBottomView.swift
//  VINNY
//
//  Created by 한태빈 on 7/17/25.
//

import SwiftUI

struct LoginBottomView: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    let assistiveText: String

    var body: some View {
        VStack{
            if !isEnabled {
                Text(assistiveText)
                    .font(.suit(.regular, size: 12))
                    .foregroundStyle(Color("ContentAssistive"))
            }

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
        .padding(.bottom, 20)
        .background(Color("BackFillRegular"))
    }
}
