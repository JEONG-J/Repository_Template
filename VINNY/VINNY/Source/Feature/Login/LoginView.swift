import SwiftUI

struct LoginView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject private var viewModel: LoginViewModel

    init(container: DIContainer) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(container: container))
    }

    var body: some View {
        NavigationStack (path: $container.navigationRouter.destinations) {
            ZStack {
                Color.backRootRegular
                    .ignoresSafeArea()
                VStack(alignment: .center) {
                    loginInfo
                    loginButtons
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                                NavigationRoutingView(destination: destination)
                                    .environmentObject(container)
                            }
            }
        }
    }
            

    private var loginInfo: some View {
        VStack(alignment: .center) {
            Image("vinnylogo")
                .resizable()
                .frame(width: 180, height: 100)
                .foregroundStyle(Color("ContentBase"))
                .padding(.vertical, 216.5)
            Text("내 손 안의 빈티지, VINNY")
                .font(.suit(.bold, size: 20))
                .foregroundStyle(Color("ContentBase"))
                .padding(.top, 16)
                .padding(.bottom, 4)
            Text("빈티지샵, 취향 공유까지 한 번에!")
                .font(.suit(.medium, size: 16))
                .foregroundStyle(Color("ContentAdditive"))
                .padding(.bottom, 16)
        }
    }

    private var loginButtons: some View {
        VStack(spacing: 8) {
            // Apple 로그인 버튼
            Button(action: {
                container.navigationRouter.push(to: .CategoryView)
            }) {
                Image("applelogin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 10)
            // 카카오 로그인 버튼
            Button(action: {
                container.navigationRouter.push(to: .CategoryView)
            }) {
                Image("kakaologin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    let container = DIContainer()
    LoginView(container: container)
        .environmentObject(container)
}
