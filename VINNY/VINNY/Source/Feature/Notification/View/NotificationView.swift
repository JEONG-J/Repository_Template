import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var container: DIContainer
    init(container: DIContainer) {}

    // MVVM: View → ViewModel 바인딩
    @State private var vm = NotificationViewModel()

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            Color.backRootRegular.ignoresSafeArea()
            VStack(spacing: 0) {
                // 상단 바
                ZStack {
                    HStack {
                        Button { container.navigationRouter.pop() } label: {
                            Image("arrowBack")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                    Text("알림")
                        .font(.suit(.bold, size: 18))
                        .foregroundStyle(.contentBase)
                }
                .padding(16)
                .padding(.bottom, 8)

                if vm.isLoading {
                    ProgressView()
                        .padding(.top, 24)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {

                            if !vm.newItems.isEmpty {
                                SectionHeader(title: "새 알림",
                                              trailingTitle: "모두 읽기",
                                              trailingAction: { vm.markAllRead() })

                                VStack(spacing: 0) {
                                    ForEach(vm.newItems) { item in
                                        NotificationRow(
                                            item: item,
                                            onRead: { vm.markRead(item) },
                                            onDelete: { vm.delete(item) }
                                        )
                                        Divider()
                                            .frame(height: 1)
                                            .background(Color.borderDividerRegular)
                                            .padding(.leading, 68)
                                    }
                                }

                                Divider()
                                    .frame(height: 4)
                                    .background(Color.borderDividerRegular)
                                    .padding(.vertical, 10)
                            }

                            SectionHeader(title: "지난 알림",
                                          trailingTitle: "모두 지우기",
                                          trailingAction: { vm.clearAllOld() })

                            VStack(spacing: 0) {
                                if vm.oldItems.isEmpty {
                                    EmptyRow()
                                } else {
                                    ForEach(vm.oldItems) { item in
                                        NotificationRow(
                                            item: item,
                                            onRead: {}, // 이미 읽음
                                            onDelete: { vm.delete(item) }
                                        )
                                        Divider()
                                            .frame(height: 1)
                                            .background(Color.borderDividerRegular)
                                            .padding(.leading, 68)
                                    }
                                }
                            }

                            Spacer(minLength: 24)
                        }
                    }
                }
            }
        }
        .task { await vm.load() }      // 최초 로드 (API 붙이면 그대로 동작)
        .navigationBarBackButtonHidden()
        .alert("오류", isPresented: .constant(vm.errorMessage != nil), actions: {
            Button("확인", role: .cancel) { vm.errorMessage = nil }
        }, message: {
            Text(vm.errorMessage ?? "")
        })
    }
}

// MARK: - Components (View 전용)

struct SectionHeader: View {
    let title: String
    let trailingTitle: String
    let trailingAction: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.contentBase)
                .font(.suit(.bold, size: 18))
            Spacer()
            Button(action: trailingAction) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                    Text(trailingTitle)
                        .font(.suit(.medium, size: 14))
                }
                .foregroundStyle(.contentAdditive)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct NotificationRow: View {
    let item: NotificationItem
    let onRead: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 썸네일
            ZStack {
                if let name = item.thumbnailName {
                    Image(name).resizable().scaledToFill()
                } else {
                    Image("emptyImage").resizable().scaledToFill()
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("{\(item.userName)}")
                    .font(.suit(.semibold, size: 16))
                    .foregroundStyle(.contentBase)
                Text(item.message)
                    .font(.suit(.medium, size: 14))
                    .foregroundStyle(.contentBase)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(item.minutesAgo)분 전")
                    .font(.suit(.regular, size: 12))
                    .foregroundStyle(.contentAssistive)
                if item.isNew {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(.contentInverted)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if item.isNew { Button("읽음", action: onRead) }
            Button(role: .destructive, action: onDelete) { Text("삭제") }
        }
        .buttonStyle(.plain)
    }
}

struct EmptyRow: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("지난 알림이 없어요")
                .font(.suit(.regular, size: 14))
                .foregroundStyle(.contentAssistive)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    let container = DIContainer()
    NotificationView(container: container)
        .environmentObject(container)
}
