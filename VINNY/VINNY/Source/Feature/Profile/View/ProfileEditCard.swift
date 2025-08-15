import SwiftUI
import PhotosUI

struct ProfileEditCard: View {
    @EnvironmentObject var container: DIContainer
    @ObservedObject var viewModel: MypageViewModel
    @Binding var isPresented: Bool

    @State private var nickname: String
    @State private var intro: String

    @State private var selectedImage: UIImage?
    @State private var profilePickerItem: PhotosPickerItem? = nil

    @State private var selectedBackgroundImage: UIImage?
    @State private var backgroundPickerItem: PhotosPickerItem? = nil

    init(isPresented: Binding<Bool>, viewModel: MypageViewModel) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self._nickname = State(initialValue: viewModel.profile?.nickname ?? "")
        self._intro = State(initialValue: viewModel.profile?.comment ?? "")
    }

    var body: some View {
        mainContent()
            .background(Color.backRootRegular)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onChange(of: profilePickerItem, initial: false) { newItem, _ in
                print("프로필 이미지 선택됨: \(String(describing: newItem))")

                Task {
                    guard let item = newItem else { return }

                    do {
                        if let data = try await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            print("프로필 이미지 로딩 성공")
                            await MainActor.run {
                                selectedImage = image
                            }
                            await viewModel.uploadProfileImage(data: data)
                        } else {
                            print("프로필 이미지 디코딩 실패")
                        }
                    } catch {
                        print("프로필 이미지 로딩 에러: \(error)")
                    }
                }
            }
            .onChange(of: backgroundPickerItem, initial: false) { newItem, _ in
                print("배경 이미지 선택됨: \(String(describing: newItem))")

                Task {
                    guard let item = newItem else { return }

                    do {
                        if let data = try await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            print("배경 이미지 로딩 성공")
                            await MainActor.run {
                                selectedBackgroundImage = image
                            }
                            await viewModel.uploadBackgroundImage(data: data)
                        } else {
                            print("배경 이미지 디코딩 실패")
                        }
                    } catch {
                        print("배경 이미지 로딩 에러: \(error)")
                    }
                }
            }
    }

    // MARK: - Main Content
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

    // MARK: - Header
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

    // MARK: - 미리보기
    @ViewBuilder
    private func profilePreview() -> some View {
        HStack {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image).resizable()
                } else if let urlString = viewModel.profile?.profileImage,
                          let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        default:
                            Image("example_profile").resizable()
                        }
                    }
                } else {
                    Image("example_profile").resizable()
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

    // MARK: - 이미지 선택
    @ViewBuilder
    private func imagePickers() -> some View {
        HStack(spacing: 8) {
            PhotosPicker(
                selection: $profilePickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image("profileimageupload")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
            }

            PhotosPicker(
                selection: $backgroundPickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image("backgroundimageupload")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }

    // MARK: - 입력 필드
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
    }

    // MARK: - 저장 버튼
    @ViewBuilder
    private func saveButton() -> some View {
        Button(action: {
            Task {
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

    // MARK: - 재사용 입력 컴포넌트
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
