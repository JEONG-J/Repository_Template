//
//  NotificationViewModel.swift
//  VINNY
//
//  Created by 한태빈 on 8/12/25.
//
import Foundation

// 서비스 프로토콜: API 붙일 때 이 인터페이스만 맞춰주면 됨
protocol NotificationServiceType {
    func fetch() async throws -> (new: [NotificationItem], old: [NotificationItem])
}

// 임시 더미(로컬) 서비스
struct MockNotificationService: NotificationServiceType {
    func fetch() async throws -> (new: [NotificationItem], old: [NotificationItem]) {
        let newItems: [NotificationItem] = [
            .init(userName: "{유저이름}", message: "{유저이름}님이 내 게시물에 좋아요를 눌렀어요", minutesAgo: 5, isNew: true),
            .init(userName: "{유저이름}", message: "{유저이름}님이 내 게시물에 좋아요를 눌렀어요", minutesAgo: 9, isNew: true)
        ]
        let oldItems: [NotificationItem] = [
            .init(userName: "{유저이름}", message: "{유저이름}님이 내 게시물에 좋아요를 눌렀어요", minutesAgo: 5, isNew: false),
            .init(userName: "{유저이름}", message: "{유저이름}님이 내 게시물에 좋아요를 눌렀어요", minutesAgo: 9, isNew: false)
        ]
        return (newItems, oldItems)
    }
}

// MVVM: ViewModel
@Observable
final class NotificationViewModel {
    private let service: NotificationServiceType

    // View에서 바인딩할 상태
    var newItems: [NotificationItem] = []
    var oldItems: [NotificationItem] = []
    var isLoading: Bool = false
    var errorMessage: String?

    init(service: NotificationServiceType = MockNotificationService()) {
        self.service = service
    }

    // 최초/새로고침 로드
    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await service.fetch()
            newItems = result.new
            oldItems = result.old
            errorMessage = nil
        } catch {
            errorMessage = "알림을 불러오지 못했어요."
        }
    }

    // 도메인 로직
    func markAllRead() {
        oldItems.insert(contentsOf: newItems.map { var x = $0; x.isNew = false; return x }, at: 0)
        newItems.removeAll()
    }

    func clearAllOld() {
        oldItems.removeAll()
    }

    func markRead(_ item: NotificationItem) {
        guard let idx = newItems.firstIndex(of: item) else { return }
        var read = newItems.remove(at: idx)
        read.isNew = false
        oldItems.insert(read, at: 0)
    }

    func delete(_ item: NotificationItem) {
        if let i = newItems.firstIndex(of: item) { newItems.remove(at: i) }
        else if let j = oldItems.firstIndex(of: item) { oldItems.remove(at: j) }
    }
}
