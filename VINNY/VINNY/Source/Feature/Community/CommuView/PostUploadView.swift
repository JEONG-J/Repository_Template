//
//  PostUploadView.swift
//  VINNY
//
//  Created by 홍지우 on 7/20/25.
//

import SwiftUI
import PhotosUI

struct PostUploadView: View {
    @EnvironmentObject var container: DIContainer
        
    init(container: DIContainer) {
        
    }
    @StateObject var viewModel = PostUploadViewModel()
    
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    
    /// 이미지 업로드 관련 상태
    @State private var showPhotosPicker = false // 포토 피커(이미지 선택 창) 표시 여부
    @State private var selectedItems: [PhotosPickerItem] = [] // 선택된 이미지 아이템들
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    private var styles: [String] = [
        "🪖 밀리터리", "🇺🇸 아메카지", "🛹 스트릿", "🏔️ 아웃도어", "👕 캐주얼", "👖 데님", "💼 하이엔드", "🛠️ 워크웨어", "👞 레더", "‍🏃‍♂️ 스포티", "🐴 웨스턴", "👚 Y2K"
    ]
    @State private var selectedStyles: Set<String> = []
    @State private var brandInput: String = "" // 브랜드 태그 입력창
    @State private var shopInput: String = "" // 샵 태그 입력창
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 상단 고정 바
            ZStack {
                HStack {
                    Button(action: {
                        print("[PostUpload] back tapped")
                        container.navigationRouter.pop()
                    }) {
                        Image("arrowBack")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }
                Text("게시글 업로드")
                    .font(.suit(.regular, size: 18))
                    .foregroundStyle(Color.contentBase)
            }
            .padding(16)
            
            Divider()
            
            // MARK: - 스크롤뷰
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // MARK: - 페이지뷰(선택된 이미지들)
                    VStack(spacing: 12) {
                        TabView(selection: $viewModel.currentIndex) {
                            if viewModel.postImages.isEmpty {
                                Image("emptyBigImage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 320)
                                    .clipped()
                                    .padding(.top, 4)
                            } else {
                                ForEach(0..<viewModel.postImages.count, id: \.self) { index in
                                    Image(uiImage: viewModel.postImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 320)
                                        .clipped()
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .frame(height: 320)
                        .padding(.vertical, 4)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .onChange(of: viewModel.postImages.count) { old, newCount in
                            if newCount <= 0 {
                                viewModel.currentIndex = 0
                            } else if viewModel.currentIndex >= newCount {
                                viewModel.currentIndex = max(0, newCount - 1)
                            }
                        }
                        
                        /// PostCard와 동일
                        HStack(spacing: 4) {
                            ForEach(0..<viewModel.selectedImageCount, id: \.self) { index in
                                Circle()
                                    .fill(index == viewModel.currentIndex ? Color.gray : Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .animation(.easeInOut, value: viewModel.currentIndex)
                        .padding(.top, 8)
                    }
                    
                    // MARK: - 이미지 선택
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Text("이미지 선택")
                                .font(.suit(.bold, size: 18))
                                .foregroundStyle(Color.contentBase)
                            
                            Spacer()
                            
                            Text("\(viewModel.selectedImageCount)개/5개")
                                .font(.suit(.light, size: 14))
                                .foregroundStyle(Color.contentAssistive)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(0..<viewModel.postImages.count, id: \.self) { index in
                                    Image(uiImage: viewModel.postImages[index])
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                /// 버튼 누를 시 이미지 선택 할 수 있도록
                                Button(action: {
                                    showPhotosPicker = true
                                }) {
                                    Image("emptyBigImage")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .photosPicker(isPresented: $showPhotosPicker,
                                              selection: $selectedItems,
                                              maxSelectionCount: 5, matching: .images,
                                              photoLibrary: .shared()
                                )
                                .onChange(of: selectedItems) { oldItems, newItems in
                                    Task {
                                        viewModel.postImages = []
                                        for item in newItems {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                viewModel.postImages.append(image)
                                            }
                                        }
                                        await MainActor.run {
                                            viewModel.currentIndex = 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // MARK: - 내용 입력
                    Rectangle()
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.borderDividerRegular)
                        .padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내용 입력")
                            .font(.suit(.bold, size: 18))
                            .foregroundStyle(Color.contentBase)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("제목")
                                .font(.suit(.medium, size: 14))
                                .foregroundStyle(Color.contentAdditive)
                            
                            TextEditor(text: $viewModel.title)
                                .customStyleEditor(placeholder: "제목은 최대 15자까지 가능해요", userInput: $viewModel.title, maxLength: 15)
                                .frame(height: 48)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("내용")
                                .font(.suit(.medium, size: 14))
                                .foregroundStyle(Color.contentAdditive)
                                .padding(.top, 10)
                                .padding(.bottom, 6)
                            
                            TextEditor(text: $viewModel.content)
                                .customStyleEditor(placeholder: "나만의 멋진 내용을 적어주세요!", userInput: $viewModel.content, maxLength: 100)
                                .frame(height: 156)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 16)
                    
                    Rectangle()
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.borderDividerRegular)
                        .padding(.vertical, 10)
                    
                    // MARK: - 스타일 선택
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Text("스타일 선택")
                                .font(.suit(.bold, size: 18))
                                .foregroundStyle(Color.contentBase)

                            Spacer()

                            Text("\(selectedStyles.count)개/3개")
                                .font(.suit(.light, size: 14))
                                .foregroundStyle(Color.contentAssistive)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                            ForEach(styles, id: \.self) { style in
                                Button(action: {
                                    print("\(style)")
                                }) {
                                    SelectingTagComponent(
                                        tag: style,
                                        selectedTag: selectedStyles.contains(style),
                                        onTap: {
                                            if selectedStyles.contains(style) {
                                                selectedStyles.remove(style)
                                            } else {
                                                if selectedStyles.count < 3 {
                                                    selectedStyles.insert(style)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - 브랜드 입력
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Text("브랜드 입력")
                                .font(.suit(.bold, size: 18))
                                .foregroundStyle(Color.contentBase)
                            
                            Spacer()
                            
                            Text("\(viewModel.brands.count)개/3개")
                                .font(.suit(.light, size: 14))
                                .foregroundStyle(Color.contentAssistive)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                            
                        TextEditor(text: $brandInput)
                            .customStyleEditor(
                                placeholder: "태그할 브랜드를 입력해주세요",
                                userInput: $brandInput,
                                maxLength: nil
                            )
                            .frame(height: 48)
                            .padding(.vertical, 8)
                            .onChange(of: brandInput) { oldValue, newValue in
                                if newValue.contains("\n") {
                                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmed.isEmpty,
                                       !viewModel.brands.contains(trimmed),
                                       viewModel.brands.count < 3 {
                                        viewModel.brands.append(trimmed)
                                    }
                                    brandInput = ""
                                }
                            }
                        
                        Text("태그된 브랜드")
                            .font(.suit(.light, size: 14))
                            .foregroundStyle(Color.contentBase)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        HStack(spacing: 8) {
                            ForEach(viewModel.brands, id: \.self) { tag in
                                BrandTagComponent(tag: tag) {
                                    viewModel.brands.removeAll() { $0 == tag }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - 빈티지샵 태그
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Text("빈티지샵 태그")
                                .font(.suit(.bold, size: 18))
                                .foregroundStyle(Color.contentBase)

                            Spacer()

                            Text(viewModel.shoptag == nil ? "0개/1개" : "1개/1개")
                                .font(.suit(.light, size: 14))
                                .foregroundStyle(Color.contentAssistive)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        
                        TextEditor(text: $shopInput)
                            .customStyleEditor(
                                placeholder: "태그할 샵 이름을 입력해주세요",
                                userInput: $shopInput,
                                maxLength: nil)
                            .frame(height: 48)
                            .padding(.vertical, 8)
                            .onChange(of: shopInput) { oldValue, newValue in
                                if newValue.contains("\n") {
                                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmed.isEmpty {
                                        viewModel.shoptag = trimmed
                                    }
                                    shopInput = "" // 초기화
                                }
                            }
                        
                        Text("태그된 샵")
                            .font(.suit(.light, size: 14))
                            .foregroundStyle(Color.contentBase)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        if let tag = viewModel.shoptag {
                            ShopTagComponent(tag: tag)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // MARK: - 하단 고정 버튼(업로드)
            Button(action: {
                Task { @MainActor in
                    print("[PostUpload] Upload tapped")
                    print("[PostUpload] State — title='\(viewModel.title)', content='\(viewModel.content)', images=\(viewModel.postImages.count), isSaving=\(isSaving)")

                    guard !isSaving else { print("[PostUpload] Skipped — already saving"); return }

                    let trimmedTitle = viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedContent = viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedTitle.isEmpty || trimmedContent.isEmpty {
                        print("[PostUpload] Validation failed — empty title or content")
                        errorMessage = "제목과 내용을 입력해주세요."
                        showErrorAlert = true
                        return
                    }

                    isSaving = true
                    defer { isSaving = false }

                    let imageDatas: [Data] = viewModel.postImages.compactMap { $0.jpegData(compressionQuality: 0.85) }
                    print("[PostUpload] Preparing request — images: \(imageDatas.count)")

                    let dto = CreatePostRequestDTO(
                        title: trimmedTitle,
                        content: trimmedContent,
                        shopId: nil,
                        styleId: nil,
                        brandId: nil
                    )

                    do {
                        let newId = try await PostAPITarget.submitPost(dto: dto, images: imageDatas)
                        print("[PostUpload] Upload success — postId: \(newId)")
                        container.navigationRouter.pop()
                    } catch {
                        print("[PostUpload] Upload failed: \(error)")
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }) {
                Text("업로드")
                    .font(.suit(.medium, size: 16))
                    .foregroundStyle(Color.contentInverted)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.backFillInverted)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.backFillRegular)
            )
        }
        .background(Color.backFillStatic)
        .navigationBarBackButtonHidden()
        .overlay(alignment: .center) {
            if isSaving { ProgressView().controlSize(.large) }
        }
        .alert("업로드 실패", isPresented: $showErrorAlert) {
            Button("확인") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "알 수 없는 오류")
        }
        .onAppear {
            print("[PostUpload] appeared")
        }
    }
    
    private func BrandTagComponent(tag: String, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text("\(tag)")
                .font(.suit(.medium, size: 14))
                .foregroundStyle(Color.contentAdditive)
            
            Button(action: {
                onDelete() // 취소 시 액션
            }) {
                Image("close")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.backFillRegular)
        )
    }
    
    private func ShopTagComponent(tag: String) -> some View {
        HStack(spacing: 8) {
            Image("emptyImage")
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(tag)")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.contentBase)
                Text("샵주소")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.contentAdditive)
            }
            Spacer()
            Button(action: {
                print("삭제") // 삭제 시 액션
                viewModel.shoptag = nil
            }) {
                HStack(spacing: 2) {
                    Image("remove")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("삭제")
                        .font(.suit(.medium, size: 14))
                        .foregroundStyle(Color.contentAdditive)
                        .padding(.vertical, 2)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(Color.backFillRegular)
                )
            }
        }
    }
}

#Preview {
    let container = DIContainer()
    PostUploadView(container: container)
        .environmentObject(container)
}
