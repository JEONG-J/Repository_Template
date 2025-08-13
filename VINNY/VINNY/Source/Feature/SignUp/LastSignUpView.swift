// LastSignUpView.swift
import SwiftUI
import Moya

struct LastSignUpView: View {
    @EnvironmentObject var container: DIContainer

    @State private var nickname: String = ""
    @State private var intro: String = ""
    @State private var isSubmitting = false
    @State private var errorText: String?

    // 공백 제거 후 1~10자만 유효
    private var isNicknameValid: Bool {
        let t = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && t.count <= 10
    }

    init(container: DIContainer) { /* 라우팅 시그 맞춤용 */ }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backRootRegular.ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단바
                ZStack {
                    HStack {
                        Button { container.navigationRouter.pop() } label: {
                            Image("arrowBack").resizable().frame(width: 24, height: 24).padding(.leading, 16)
                        }
                        Spacer()
                    }
                    Text("가입하기")
                        .font(.suit(.regular, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .frame(height: 60)

                // 타이틀
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

                // 입력
                VStack(spacing: 16) {
                    inputField(title: "닉네임", text: $nickname, placeholder: "새 닉네임을 입력해주세요", limit: 10)
                    inputField(title: "한줄 소개", text: $intro, placeholder: "새 한줄 소개를 입력해주세요", limit: 20)
                }
                .frame(height: 240)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 241)

                // 하단 버튼 (LocationView 패턴 동일)
                LoginBottomView(
                    title: isNicknameValid ? (isSubmitting ? "저장 중..." : "완료하기") : "다음으로",
                    isEnabled: isNicknameValid && !isSubmitting,
                    action: submit,
                    assistiveText: "닉네임을 입력해야 넘어갈 수 있어요."
                )
                .frame(height: 104)
            }
        }
        .alert("저장 실패",
               isPresented: Binding(
                   get: { errorText != nil },
                   set: { if !$0 { errorText = nil } }
               )) {
            Button("확인") { errorText = nil }
        } message: { Text(errorText ?? "") }
        .navigationBarBackButtonHidden()
        .onAppear {
            // 기존 선택값 있으면 프리필
            nickname = container.onboardingSelection.nickname
            intro    = container.onboardingSelection.comment
        }
        .onChange(of: nickname) { container.onboardingSelection.nickname = $0 }
        .onChange(of: intro)    { container.onboardingSelection.comment  = $0 }
    }

    // MARK: - Submit (여기서 최종 온보딩 API 호출)
    private func submit() {
        guard isNicknameValid else { return }

        let s = container.onboardingSelection
        let nick = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let introTrim = intro.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !nick.isEmpty,
            !introTrim.isEmpty,
            (OnboardingSelection.Limit.styleMin ... OnboardingSelection.Limit.styleMax).contains(s.vintageStyleIds.count),
            (OnboardingSelection.Limit.brandMin ... OnboardingSelection.Limit.brandMax).contains(s.brandIds.count),
            (OnboardingSelection.Limit.itemMin  ... OnboardingSelection.Limit.itemMax ).contains(s.vintageItemIds.count),
            (OnboardingSelection.Limit.areaMin  ... OnboardingSelection.Limit.areaMax ).contains(s.regionIds.count)
        else {
            errorText = "선택값을 다시 확인해주세요."
            return
        }

        isSubmitting = true
        errorText = nil

        

        let dto = OnboardRequestDTO(
            vintageStyleIds: Array(s.vintageStyleIds),
            brandIds:       Array(s.brandIds),
            vintageItemIds: Array(s.vintageItemIds),
            regionIds:      Array(s.regionIds),
            nickname:       nick,
            comment:        introTrim
        )
        // 디버그 로그
        print("📦 onboard payload:",
              "styles:", dto.vintageStyleIds,
              "brands:", dto.brandIds,
              "items:", dto.vintageItemIds,
              "regions:", dto.regionIds,
              "nick:", dto.nickname,
              "comment:", dto.comment)

        // 공용 프로바이더로 요청 (LocationView와 동일 패턴)
        container.useCaseProvider.onboardUseCase.request(.submit(dto: dto)) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let res) where (200..<300).contains(res.statusCode):
                    print("✅ Onboarding success:", res.statusCode)
                    container.onboardingSelection.reset()
                    container.navigationRouter.push(to: .HomeView)
                case .success(let res):
                    let bodyStr = String(data: res.data, encoding: .utf8) ?? "no body"
                    print("⛔️ Onboarding failed:", res.statusCode, bodyStr)
                    errorText = "오류가 발생했어요. (\(res.statusCode))"
                case .failure(let err):
                    print("❌ Onboarding error:", err)
                    errorText = "네트워크 오류가 발생했어요."
                }
            }
        }
    }

    // MARK: - UI helpers (LocationView 스타일 그대로)
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
                .overlay(alignment: .trailing) {
                    Button { text.wrappedValue = "" } label: {
                        Image("close").resizable().frame(width: 20, height: 20)
                            .foregroundStyle(Color("ContentAssistive"))
                            .padding(.trailing, 16)
                    }
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
