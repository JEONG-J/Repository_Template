import SwiftUI

struct LoginView: View {
    @EnvironmentObject var container: DIContainer

    init(container: DIContainer) {
        
    }

    var body: some View {
        NavigationStack (path: $container.navigationRouter.destinations) {
            ZStack {
                Color.backRootRegular
                    .ignoresSafeArea()
                VStack(alignment: .center) {
                    loginInfo
                    loginButton
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
            Spacer().frame(height: 240)
            Image("vinnylogo")
                .resizable()
                .frame(width: 180, height: 100)
                .foregroundStyle(Color("ContentBase"))
            Spacer().frame(height: 240)
            Text("내 손 안의 빈티지, VINNY")
                .font(.suit(.bold, size: 20))
                .foregroundStyle(Color("ContentBase"))
            Spacer().frame(height: 2)
            Text("빈티지샵, 취향 공유까지 한 번에!")
                .font(.suit(.medium, size: 16))
                .foregroundStyle(Color("ContentAdditive"))
            Spacer().frame(height: 26)
        }
    }

    private var loginButton: some View {
        Button(action: {
            container.navigationRouter.push(to: .CategoryView)
        }) {
            Text("카카오로 시작하기")
                .font(.suit(.medium, size: 16))
                .foregroundStyle(Color("ContentInverted"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("BackFillInverted"))
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    let container = DIContainer()
    LoginView(container: container)
        .environmentObject(container)
}
