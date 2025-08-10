//
//  LocationView.swift
//  VINNY
//
//  Created by 한태빈 on 7/6/25.
//

import SwiftUI
import Moya

struct LocationView: View {
    @EnvironmentObject var container: DIContainer
    @State private var isSubmitting = false
    private let options = OnboardingCatalog.regions   // [OnboardOption]
    private let maxSelectionCount = OnboardingSelection.Limit.areaMax
    
    init(container: DIContainer) {
        // 비워둠: 라우팅 시그니처 맞추기용
    }
    
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backRootRegular
                .ignoresSafeArea()
            VStack(spacing: 0) {
                //상단바
                ZStack {
                    HStack {
                        Button (action: {
                            container.navigationRouter.pop()                 }) {
                                Image("arrowBack")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.leading, 16)
                                
                            }
                        Spacer()
                    }
                    Text("가입하기")
                        .font(.suit(.regular, size: 18))
                        .foregroundStyle(Color.contentBase)
                }
                .frame(height: 60)
                
                VStack(spacing: 2) {
                    Text("마지막이에요! 관심 지역을 선택해주세요")
                        .font(.suit(.bold, size: 20))
                        .foregroundStyle(Color("ContentBase"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("최대 3개까지 선택할 수 있어요.")
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color("ContentAdditive"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 59)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(options) { opt in
                        let isSelected = container.onboardingSelection.regionIds.contains(opt.id)
                        Text(opt.title)
                            .font(.suit(.regular, size: 16))
                            .foregroundStyle(isSelected ? Color("ContentAdditive") : Color("ContentDisabled"))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color("BorderOutlineStrong") : Color("BackFillRegular"), lineWidth: 2)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("BackFillRegular"))
                            )
                            .onTapGesture { toggle(opt.id) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 154.5)
                
                LoginBottomView(
                    title: "완료하기",
                    isEnabled: !container.onboardingSelection.regionIds.isEmpty && !isSubmitting,
                    action: { submit() },
                    assistiveText: "최소 한 개를 선택해야 다음으로 넘어갈 수 있어요"
                )
                .frame(height: 104)
            }
            
        }
        .navigationBarBackButtonHidden()
    }
    
    private func toggle(_ id: Int) {
        var set = container.onboardingSelection.regionIds
        if set.contains(id) {
            set.remove(id)
        } else if set.count < maxSelectionCount {
            set.insert(id)
        }
        container.onboardingSelection.regionIds = set
    }
    
    private func submit() {
        // 1) 개수 검증
        guard (OnboardingSelection.Limit.areaMin...OnboardingSelection.Limit.areaMax).contains(container.onboardingSelection.regionIds.count) else { print("❗️region count invalid"); return }
        guard (OnboardingSelection.Limit.styleMin...OnboardingSelection.Limit.styleMax).contains(container.onboardingSelection.vintageStyleIds.count) else { print("❗️style count invalid"); return }
        guard (OnboardingSelection.Limit.brandMin...OnboardingSelection.Limit.brandMax).contains(container.onboardingSelection.brandIds.count) else { print("❗️brand count invalid"); return }
        guard (OnboardingSelection.Limit.itemMin...OnboardingSelection.Limit.itemMax).contains(container.onboardingSelection.vintageItemIds.count) else { print("❗️item count invalid"); return }
        
        isSubmitting = true
        
        let s = container.onboardingSelection
        let body = OnboardRequestDTO(
            vintageStyleIds: Array(s.vintageStyleIds),
            brandIds: Array(s.brandIds),
            vintageItemIds: Array(s.vintageItemIds),
            regionIds: Array(s.regionIds)
        )
        
        // 2) 디버깅 로그(필수)
        print("⛳️ counts  style:\(s.vintageStyleIds.count)  brand:\(s.brandIds.count)  item:\(s.vintageItemIds.count)  region:\(s.regionIds.count)")
        print("📦 payload  styles:\(body.vintageStyleIds)  brands:\(body.brandIds)  items:\(body.vintageItemIds)  regions:\(body.regionIds)")
        
        
        // ⛔️ 이 줄은 제거하세요 (로컬 프로바이더라 토큰 안 붙음)
        // let provider = MoyaProvider<OnboardAPITarget>()
        
        // 3) 공용 프로바이더(토큰 플러그인 포함)로 요청
        container.useCaseProvider.onboardUseCase.request(.submit(dto: body)) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let res) where (200..<300).contains(res.statusCode):
                    print("✅ Onboarding success:", res.statusCode)
                    container.navigationRouter.push(to: .VinnyTabView)
                    container.onboardingSelection.reset()
                case .success(let res):
                    print("⛔️ Onboarding failed: status=\(res.statusCode)")
                    print("↩️ body:", String(data: res.data, encoding: .utf8) ?? "no body")
                case .failure(let err):
                    print("❌ Onboarding error:", err)
                }
            }
        }
    }
}
