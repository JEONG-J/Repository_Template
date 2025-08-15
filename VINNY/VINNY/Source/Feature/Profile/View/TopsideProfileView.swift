import SwiftUI
import Kingfisher

struct TopsideProfileView: View {
    @State private var isProfileEditPresented = false
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var viewModel: MypageViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // 배경 이미지 (없으면 noneBackground)
            KFImage(URL(string: viewModel.profile?.backgroundImage ?? ""))
                .placeholder {
                    ProgressView()
                }
                .onFailureImage(UIImage(named: "noneBackGround"))
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.width
                )
                .clipped() // 넘치는 부분 잘라냄
            VStack(spacing: 24) {
                HStack {
                    Text("프로필")
                        .font(.suit(.bold, size: 24))
                        .foregroundStyle(Color("ContentBase"))
                    Spacer()
                    Button {
                        container.navigationRouter.push(to: .SettingView)
                    } label: {
                        Image("settingbutton")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color("ContentBase"))
                    }
                }
                .padding(.top, 13)
                .padding(.horizontal, 16)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 12) {
                    //프로필 이미지 (없으면 noneProfile)
                    KFImage(URL(string: viewModel.profile?.profileImage ?? ""))
                        .placeholder {
                            ProgressView()
                        }
                        .onFailureImage(UIImage(named: "noneProfile"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .padding(.leading, 16)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.profile?.nickname ?? "")
                            .font(.suit(.medium, size: 18))
                            .foregroundStyle(Color("ContentBase"))
                        
                        // 한줄소개가 없을 경우 기본 문구
                        Text(viewModel.profile?.comment ?? "")
                            .font(.suit(.regular, size: 12))
                            .foregroundStyle(Color("ContentAdditive"))
                    }
                    
                    Spacer()
                    
                    Button {
                        isProfileEditPresented = true
                    } label: {
                        HStack(spacing: 2) {
                            Image("pencil")
                            Text("편집")
                        }
                        .font(.suit(.medium, size: 14))
                        .foregroundStyle(Color("ContentBase"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.backFillRegular)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $isProfileEditPresented) {
            ProfileEditCard(isPresented: $isProfileEditPresented, viewModel: viewModel)
                .presentationDetents([.height(520)])
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .presentationBackground(Color.backRootRegular)
        }
        .onChange(of: isProfileEditPresented) { _, newValue in
            if newValue == false {
                print("프로필 편집 모달 닫힘 → fetchProfile 재호출")
//                Task {
//                    viewModel.fetchProfile()
//                }
            }
        }
    }
}
