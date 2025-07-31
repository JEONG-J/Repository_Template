//
//  SearchFocusView.swift
//  VINNY
//
//  Created by 소민준 on 7/26/25.
//


import SwiftUI

struct AutoFocusTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = "빈티지샵, 게시글 검색하기"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.keyboardType = .default
        textField.returnKeyType = .search
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFocused {
            DispatchQueue.main.async {
                if !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                }
            }
        } else {
            DispatchQueue.main.async {
                if uiView.isFirstResponder {
                    uiView.resignFirstResponder()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

struct SearchFocusView: View {
    @EnvironmentObject var container: DIContainer
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    container.navigationRouter.pop()
                }) {
                    Image("arrowBack")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44, alignment: .center)
                }
                Spacer()
                Text("검색하기")
                    .font(.suit(.bold, size: 20))
                    .foregroundColor(.white)
                    .frame(height: 44)
                Spacer()
                Spacer(minLength: 44) // reserves at least 44 pts without forcing an invalid layout
            }
            .padding(.top, 16)

            // Search Bar
            Button(action: {
                // Optional: implement search action trigger
            }) {
                HStack(spacing: 8) {
                    Image("magnifier")
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text("빈티지샵, 게시글 검색하기")
                        .font(.suit(.regular, size: 16))
                        .foregroundStyle(Color.contentAssistive)

                    Spacer()

                    Image("close")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.backFillRegular)
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Recommended Keywords
                    Text("추천 검색어")
                        .font(.suit(.semibold, size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 18)
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["홍대 데님", "칼하트", "하이엔드 빈티지", "폴로", "슈프림"], id: \.self) { keyword in
                                Text(keyword)
                                    .font(.suit(.medium, size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.backFillRegular)
                                    )
                                    .foregroundStyle(Color.contentBase)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Recent Keywords
                    HStack {
                        Text("최근 검색어")
                            .font(.suit(.semibold, size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Button("모두 삭제") {
                            // TODO: clear all logic
                        }
                        .font(.suit(.regular, size: 14))
                        .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        ForEach(["밀리언아카이브", "홍대 데님", "조휴일"], id: \.self) { keyword in
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text(keyword)
                                    .font(.suit(.regular, size: 15))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    // TODO: remove item logic
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 12)
            .onTapGesture {
                isTextFieldFocused = false
            }

            Spacer()
        }
        .background(Color.backRootRegular.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}
