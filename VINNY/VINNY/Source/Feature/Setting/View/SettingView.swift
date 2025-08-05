import SwiftUI

struct SettingView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer){
        
    }
    @State private var isLikedNotificationOn: Bool = false

    var body: some View {
        ZStack {
            Color.backRootRegular.ignoresSafeArea()
            VStack(spacing: 0) {
                // 상단 바
                ZStack {
                    HStack {
                        Button (action: {
                            container.navigationRouter.pop()                 }) {
                            Image("arrowBack")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                    Text("설정")
                        .font(.suit(.bold, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .padding(16)
                .padding(.bottom, 8)
                // 1. 취향 재설정
                SettingNavigationRow(title: "취향 재설정", icon: "reset"){
                    container.navigationRouter.push(to: .TasteResetView)
                }

                Divider()
                    .frame(height: 4)
                    .background(Color.borderDividerRegular)
                    .padding(.vertical, 10)

                // 2. 좋아요 알림 Toggle
                Text("알림")
                    .foregroundStyle(.contentBase)
                    .font(.suit(.medium, size: 18))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                
                HStack {
                    HStack(spacing: 8) {
                        Image("notify")
                            .foregroundStyle(.contentBase)
                        Text("좋아요 알림")
                            .foregroundStyle(.contentBase)
                            .font(.suit(.medium, size: 16))
                    }
                    Spacer()
                    //토글 커스텀하기
                    Toggle("", isOn: $isLikedNotificationOn)
                        .labelsHidden()
                        .foregroundStyle(.contentInverted)
                        .tint(.contentInverted)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)

                Divider()
                    .frame(height: 4)
                    .background(Color.borderDividerRegular)
                    .padding(.vertical, 10)


                // 3. 이용 약관
                Text("이용 약관")
                    .foregroundStyle(.contentBase)
                    .font(.suit(.medium, size: 18))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                
                Group {
                    SettingNavigationRow(title: "서비스 이용약관", icon: "list"){
                        
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.borderDividerRegular)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    SettingNavigationRow(title: "개인정보 처리방침", icon: "person"){
                        
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.borderDividerRegular)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    SettingNavigationRow(title: "위치 기반 서비스 이용약관", icon: "location_search"){
                        
                    }
                }

                Divider()
                    .frame(height: 4)
                    .background(Color.borderDividerRegular)
                    .padding(.vertical, 10)

                // 4. 관리
                Text("관리")
                    .foregroundStyle(.contentBase)
                    .font(.suit(.medium, size: 18))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                
                Group {
                    SettingNavigationRow(title: "로그아웃", icon: "logout"){
                        
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.borderDividerRegular)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    SettingNavigationRow(title: "회원 탈퇴", icon: "leave"){
                        
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct SettingNavigationRow: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 8) {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.contentBase)
                    Text(title)
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(.contentBase)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.contentAdditive)
            }
            .padding(.leading, 16)
            .padding(.trailing, 14)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    let container = DIContainer()
    SettingView(container: container)
        .environmentObject(container)
}
