//
//  PostView.swift
//  VINNY
//
//  Created by 한태빈 on 7/24/25.
//

import SwiftUI

struct ProfileEditCard: View {
    @State private var nickname: String = ""
    @State private var intro: String = ""
    var body: some View {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color("BorderDividerRegular"))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)
                
                HStack{
                    Text("프로필 편집")
                        .font(.suit(.bold, size: 24))
                        .foregroundStyle(Color.contentBase)
                    
                    Spacer()
                    
                    Button {
                        print("닫기버튼 클릭")
                    } label: {
                        Image("close")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.contentBase)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.all, 16)
                
                HStack(alignment: .center, spacing: 12) {
                    Image("example_profile")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("다른 사람들에게 아래와 같이 표시됩니다")
                            .font(.suit(.medium, size: 12))
                            .foregroundStyle(Color("ContentAdditive"))
                        Text("조휴일")
                            .font(.suit(.medium, size: 18))
                            .foregroundStyle(Color("ContentBase"))
                        Text("개펑크정신")
                            .font(.suit(.regular, size: 12))
                            .foregroundStyle(Color("ContentAdditive"))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                
                Button(action: {
                    Task {
                        print("이미지 업로드 클릭")
                    }
                }) {
                    Image("imageupload")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                    
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                
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
                .padding(.horizontal, 16)
                
                Button(action: {
                    Task {
                        print("이미지 업로드 클릭")
                    }
                }) {
                    Text("저장하기")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle( Color("ContentInverted"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background( Color("BackFillInverted"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
            }
            .foregroundStyle(Color("BackFillRegular"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    
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

#Preview {
    ProfileEditCard()
}
