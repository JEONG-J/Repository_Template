//
//  CustomStyleEditor.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI

struct CustomTextEditorStyle: ViewModifier {
    let placeholder: String
    @Binding var text: String // 글자 수 받기 위해 @Binding 사용
    let showCount: Bool
    let maxLength: Int?
    
    func body(content: Content) -> some View {
        content
            .font(.suit(.light, size: 16))
            .foregroundStyle(Color.contentAdditive)
            .padding(.vertical,4)
            .padding(.horizontal, 12)
            .background(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.suit(.light, size: 16))
                        .foregroundStyle(Color.contentAssistive)
                        .padding(.top, 12) // 정확히 맞추기
                        .padding(.leading, 16)
                }
            }
            .autocorrectionDisabled() /// 자동 오타 수정 기능 끄기
            .background(Color.backFillRegular)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scrollContentBackground(.hidden)
            .modifier(ConditionalOverlay(show: showCount, text: $text, maxLength: maxLength))
    }
}

struct ConditionalOverlay: ViewModifier {
    let show: Bool
    @Binding var text: String
    let maxLength: Int?
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            if show {
                content.overlay(alignment: .topTrailing) {
                    Button(action: {
                        print("지우기")
                        text = ""
                    }) {
                        Image("close")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.top, 12)
                            .padding(.trailing, 16)
                    }
                    .onChange(of: text) {
                        if let maxLength, text.count > maxLength {
                            text = String(text.prefix(maxLength))
                        }
                    }
                }
            } else {
                content
            }
        }
    }
}

extension TextEditor {
    func customStyleEditor(
        placeholder: String,
        userInput: Binding<String>,
        showCount: Bool = true,
        maxLength: Int? = nil // nil이면 글자 수 제한 없음
    ) -> some View {
        self.modifier(CustomTextEditorStyle(
            placeholder: placeholder,
            text: userInput,
            showCount: showCount,
            maxLength: maxLength
        ))
    }
}
