//
//  LocationView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI

struct LastSignUpView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    
    @State private var nickname: String = ""
    @State private var intro: String = ""

    // 공백 제거 후 1~10자만 유효로 간주
    private var isNicknameValid: Bool {
        let t = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && t.count <= 10
    }
    
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.backRootRegular
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    //상단바
                    ZStack {
                        HStack {
                            Button (action: {
                                container.navigationRouter.pop()                 }) {
                                Image("arrowBack")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.leading, 16)

                            }
                            Spacer()
                        }
                        Text("가입하기")
                            .font(.suit(.regular, size: 18))
                            .foregroundStyle(Color.contentBase)
                    }
                    .frame(height: 60)
                    
                    VStack(spacing: 2) {
                        Text("마지막이에요,\n닉네임과 한줄 소개를 입력해주세요!")
                            .font(.suit(.bold, size: 20))
                            .foregroundStyle(Color("ContentBase"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("나중에 프로필에서 수정할 수 있어요.")
                            .font(.suit(.medium, size: 16))
                            .foregroundStyle(Color("ContentAdditive"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 87)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    VStack(spacing: 16) {
                        inputField(
                            title: "닉네임",
                            text: $nickname,
                            placeholder: "새 닉네임을 입력해주세요",
                            limit: 10
                        )
                        inputField(
                            title: "한줄 소개",
                            text: $intro,
                            placeholder: "새 한줄 소개를 입력해주세요",
                            limit: 20
                        )
                    }
                    .frame(height: 240)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 241)
                    
                    LoginBottomView(
                        title: isNicknameValid ? "완료하기" : "다음으로",
                        isEnabled: isNicknameValid,
                        action: {
                            container.navigationRouter.push(to: .VinnyTabView)
                        },
                        assistiveText: "닉네임을 입력해야 넘어갈 수 있어요."
                    )
                    .frame(height: 104)
                }

            }
            .navigationBarBackButtonHidden()
        }
    
    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        limit: Int
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.suit(.medium, size: 14))
                .foregroundStyle(Color.contentAdditive)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.suit(.regular, size: 16))
                        .foregroundColor(Color("ContentAssistive"))
                        .padding(.leading, 16)
                }

                TextField("", text: Binding(
                    get: { text.wrappedValue },
                    set: { newVal in text.wrappedValue = String(newVal.prefix(limit)) }
                ))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.leading, 16)
                .frame(height: 48)
                .foregroundStyle(Color("ContentAssistive"))
                .tint(Color("ContentAssistive"))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("BackFillRegular"))
                )
            }
            .overlay(alignment: .trailing) {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image("close")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("ContentAssistive"))
                        .padding(.trailing, 16)
                }
            }

            Text("\(text.wrappedValue.count)자 / \(limit)자")
                .font(.suit(.regular, size: 12))
                .foregroundStyle(Color("ContentAssistive"))
                .padding(.horizontal, 4)
                .padding(.top, 10)

        }
    }
    }



#Preview {
    let container = DIContainer()
    LastSignUpView(container: container)
        .environmentObject(container)
}
