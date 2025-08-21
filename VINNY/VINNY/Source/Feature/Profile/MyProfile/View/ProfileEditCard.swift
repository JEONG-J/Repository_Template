import SwiftUI

/// 프로필 편집 바텀시트 카드
/// - Displays: 프로필 이미지/배경 이미지 선택, 닉네임/소개 입력, 저장 액션
/// - UX: 이미지 피커 2종(프로필/배경), 저장 시 최신 프로필 다시 조회
struct ProfileEditCard: View {
    // MARK: - Dependencies
    @EnvironmentObject var container: DIContainer
    @ObservedObject var viewModel: MypageViewModel
    @Binding var isPresented: Bool

    // MARK: - Dependencies
    @State private var nickname: String
    @State private var intro: String

    // MARK: - State (Inputs)
    @State private var selectedImage: UIImage?
    @State private var selectedBackgroundImage: UIImage?

    // MARK: - State (Sheet toggles)
    @State private var showingProfileImagePicker = false
    @State private var showingBackgroundImagePicker = false

    /// 초기값을 ViewModel의 현재 프로필에서 가져옴
    /// - Note: 바인딩 값은 시트가 뜰 때 스냅샷되어 들어옴(실시간 반영 아님)
    init(isPresented: Binding<Bool>, viewModel: MypageViewModel) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self._nickname = State(initialValue: viewModel.profile?.nickname ?? "")
        self._intro = State(initialValue: viewModel.profile?.comment ?? "")
    }

    // MARK: - Body
    var body: some View {
        mainContent()
            .background(Color.backRootRegular)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // MARK: Profile Image Picker
            .sheet(isPresented: $showingProfileImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    self.selectedImage = image
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        Task {
                            // TODO: 업로드 중 로딩 인디케이터 표시(disable 버튼 등)
                            let success = await viewModel.uploadProfileImage(data: data)
                            if success {
                                isPresented = false
                            }
                        }
                    }
                }
            }
            // MARK: Background Image Picker
            .sheet(isPresented: $showingBackgroundImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    self.selectedBackgroundImage = image
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        Task {
                            // TODO: 업로드 실패시 토스트/알럿 노출
                            let success = await viewModel.uploadBackgroundImage(data: data)
                            if success {
                                isPresented = false
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Sections

    /// 메인 레이아웃(구간별로 분리: 헤더/미리보기/이미지 버튼/입력/저장)
    @ViewBuilder
    private func mainContent() -> some View {
        VStack(spacing: 0) {
            header()
            profilePreview()
            imagePickers()
            inputFields()
            saveButton()
        }
    }

    /// 상단 드래그 바 + 타이틀 + 닫기 버튼
    @ViewBuilder
    private func header() -> some View {
        Capsule()
            .fill(Color("BorderDividerRegular"))
            .frame(width: 40, height: 4)
            .padding(.top, 8)

        HStack {
            Text("프로필 편집")
                .font(.suit(.bold, size: 24))
                .foregroundStyle(Color.contentBase)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Image("close")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.contentBase)
                    .contentShape(Rectangle())
            }
        }
        .padding(16)
    }

    /// 업로드/기존/플레이스홀더 중 우선순위로 프로필 미리보기
    @ViewBuilder
    private func profilePreview() -> some View {
        HStack {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let urlString = viewModel.profile?.profileImage,
                          let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Image("noneProfile").resizable()
                        }
                    }
                } else {
                    Image("noneProfile").resizable()
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("다른 사람들에게 아래와 같이 표시됩니다")
                    .font(.suit(.medium, size: 12))
                    .foregroundStyle(Color("ContentAdditive"))
                Text(nickname)
                    .font(.suit(.medium, size: 18))
                    .foregroundStyle(Color("ContentBase"))
                Text(intro)
                    .font(.suit(.regular, size: 12))
                    .foregroundStyle(Color("ContentAdditive"))
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, -100)
    }

    /// 프로필/배경 이미지 선택 버튼들
    @ViewBuilder
    private func imagePickers() -> some View {
        HStack(spacing: 8) {
            Button {
                showingProfileImagePicker = true
            } label: {
                Image("profileimageupload")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
            }

            Button {
                showingBackgroundImagePicker = true
            } label: {
                Image("backgroundimageupload")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    /// 닉네임/한줄 소개 입력 섹션
    @ViewBuilder
    private func inputFields() -> some View {
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
        // TODO: 접근성(VoiceOver 라벨), 에러 메시지(길이 초과, 금지어 등) UI 추가
    }

    /// 저장 버튼(프로필 업데이트 → 최신 프로필 재조회)
    @ViewBuilder
    private func saveButton() -> some View {
        Button(action: {
            Task {
                // TODO: 중복 탭 방지(disabled 상태/로딩 표시)
                viewModel.updateProfile(nickname: nickname, comment: intro)
                await viewModel.fetchProfile()
                await MainActor.run {
                    isPresented = false
                }
            }
        }) {
            Text("저장하기")
                .font(.suit(.medium, size: 16))
                .foregroundStyle(Color("ContentInverted"))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color("BackFillInverted"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    // MARK: - Reusable Components

    /// 라벨/텍스트필드/지우기 버튼/카운터를 포함한 재사용 입력 필드
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
                        .foregroundStyle(Color("ContentAssistive"))
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
            // TODO: 실시간 유효성(중복 닉네임 체크 등) 결과 표시
        }
    }
}
