
import SwiftUI
import PhotosUI

private struct TaggedBrand: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageUrl: String
}

private struct TaggedShop: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let address: String
}

// This view was already well-defined and didn't need changes.
private struct ShopSuggestionRow: View {
    let suggestion: AutoCompleteShopDTO
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: suggestion.imageUrl)) { img in
                    img.resizable()
                } placeholder: {
                    Image("emptyImage").resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.name)
                        .font(.suit(.medium, size: 16))
                        .foregroundStyle(Color.contentBase)
                    Text(suggestion.address)
                        .font(.suit(.light, size: 12))
                        .foregroundStyle(Color.contentAdditive)
                }
                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.backFillRegular)
            )
        }
    }
}

// This view was also well-defined.
private struct BrandSuggestionRow: View {
    let suggestion: AutoCompleteBrandDTO
    let onSelect: ()->Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: suggestion.imageUrl)) { img in
                    img.resizable()
                } placeholder: {
                    Image("emptyBrand").resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                Text(suggestion.keyword)
                    .font(.suit(.medium, size: 16))
                    .foregroundStyle(Color.contentBase)
                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.backFillRegular)
            )
        }
    }
}

struct PostUploadView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject var viewModel = PostUploadViewModel()

    // MARK: - State Properties
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    
    // Image selection
    @State private var showPhotosPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // Style selection
    @State private var selectedStyles: Set<String> = []
    
    // Brand input
    @State private var brandInput: String = ""
    @State private var brandSuggestions: [AutoCompleteBrandDTO] = []
    @State private var brands: [TaggedBrand] = []
    @State private var taggedShop: TaggedShop? = nil
    // Shop input
    @State private var shopInput: String = ""
    @State private var shopSuggestions: [AutoCompleteShopDTO] = []
    
    @FocusState private var focusedField: Field?
    private enum Field { case title, content, brand, shop }
    
    // MARK: - Static Properties
    private let styles: [String] = [
        "🪖 밀리터리", "🇺🇸 아메카지", "🛹 스트릿", "🏔️ 아웃도어", "👕 캐주얼",
        "👖 데님", "💼 하이엔드", "🛠️ 워크웨어", "👞 레더", "‍🏃‍♂️ 스포티",
        "🐴 웨스턴", "👚 Y2K"
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    init(container: DIContainer) {
        // Initialization if needed
    }

    // MARK: - Main Body
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ImagePagerView(viewModel: viewModel)
                    
                    ImageSelectionSection(
                        viewModel: viewModel,
                        showPhotosPicker: $showPhotosPicker,
                        selectedItems: $selectedItems
                    )
                    
                    divider
                    
                    ContentInputSection(
                        viewModel: viewModel,
                        focusedField: $focusedField
                    )
                    
                    divider

                    StyleSelectionSection(
                        selectedStyles: $selectedStyles,
                        styles: styles,
                        columns: columns
                    )

                    BrandInputSection(
                        viewModel: viewModel,
                        brandInput: $brandInput,
                        brandSuggestions: $brandSuggestions,
                        brands: $brands,                    // ★ 추가
                        focusedField: $focusedField
                    )

                    ShopTagSection(
                        viewModel: viewModel,
                        shopInput: $shopInput,
                        shopSuggestions: $shopSuggestions,
                        taggedShop: $taggedShop,
                        focusedField: $focusedField
                    )
                    
                    Spacer().frame(height: 280)
                }
            }
            
            uploadButton
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
        .simultaneousGesture(TapGesture().onEnded {
            focusedField = nil
        })
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Refactored Subviews
private extension PostUploadView {
    
    var header: some View {
        ZStack {
            HStack {
                Button(action: {
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
    }
    
    var divider: some View {
        Rectangle()
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.borderDividerRegular)
            .padding(.vertical, 10)
    }
    
    var uploadButton: some View {
        Button(action: uploadPost) {
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
    
    // MARK: - UI Components
    
    private struct ImagePagerView: View {
        @ObservedObject var viewModel: PostUploadViewModel
        
        var body: some View {
            VStack(spacing: 12) {
                TabView(selection: $viewModel.currentIndex) {
                    if viewModel.postImages.isEmpty {
                        Image("emptyBigImage")
                            .resizable().scaledToFill().frame(height: 320).clipped()
                            .padding(.top, 4)
                    } else {
                        ForEach(0..<viewModel.postImages.count, id: \.self) { index in
                            Image(uiImage: viewModel.postImages[index])
                                .resizable().scaledToFill().frame(height: 320).clipped()
                                .padding(.top, 4)
                        }
                    }
                }
                .frame(height: 320)
                .padding(.vertical, 4)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: viewModel.postImages.count) { _, newCount in
                    if newCount <= 0 {
                        viewModel.currentIndex = 0
                    } else if viewModel.currentIndex >= newCount {
                        viewModel.currentIndex = max(0, newCount - 1)
                    }
                }
                
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
        }
    }
    
    private struct ImageSelectionSection: View {
        @ObservedObject var viewModel: PostUploadViewModel
        @Binding var showPhotosPicker: Bool
        @Binding var selectedItems: [PhotosPickerItem]
        
        var body: some View {
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
                        
                        Button(action: { showPhotosPicker = true }) {
                            Image("imagePicker")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItems, maxSelectionCount: 5, matching: .images, photoLibrary: .shared())
                        .onChange(of: selectedItems) { _, newItems in
                            Task {
                                viewModel.postImages = []
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
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
        }
    }
    
    private struct ContentInputSection: View {
        @ObservedObject var viewModel: PostUploadViewModel
        @FocusState.Binding var focusedField: Field?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("내용 입력")
                    .font(.suit(.bold, size: 18))
                    .foregroundStyle(Color.contentBase)
                    .padding(.top, 10).padding(.bottom, 6)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목").font(.suit(.medium, size: 14)).foregroundStyle(Color.contentAdditive)
                    TextEditor(text: $viewModel.title)
                        .customStyleEditor(placeholder: "제목은 최대 15자까지 가능해요", userInput: $viewModel.title, maxLength: 15)
                        .frame(height: 48)
                        .focused($focusedField, equals: .title)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("내용").font(.suit(.medium, size: 14)).foregroundStyle(Color.contentAdditive)
                        .padding(.top, 10).padding(.bottom, 6)
                    TextEditor(text: $viewModel.content)
                        .customStyleEditor(placeholder: "나만의 멋진 내용을 적어주세요!", userInput: $viewModel.content, maxLength: 100)
                        .frame(height: 156)
                        .focused($focusedField, equals: .content)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private struct StyleSelectionSection: View {
        @Binding var selectedStyles: Set<String>
        let styles: [String]
        let columns: [GridItem]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("스타일 선택").font(.suit(.bold, size: 18)).foregroundStyle(Color.contentBase)
                    Spacer()
                    Text("\(selectedStyles.count)개/3개").font(.suit(.light, size: 14)).foregroundStyle(Color.contentAssistive)
                }
                .padding(.top, 10).padding(.bottom, 6)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(styles, id: \.self) { style in
                        SelectingTagComponent(
                            tag: style,
                            selectedTag: selectedStyles.contains(style),
                            onTap: {
                                if selectedStyles.contains(style) {
                                    selectedStyles.remove(style)
                                } else if selectedStyles.count < 3 {
                                    selectedStyles.insert(style)
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private struct BrandInputSection: View {
        @ObservedObject var viewModel: PostUploadViewModel
        @Binding var brandInput: String
        @Binding var brandSuggestions: [AutoCompleteBrandDTO]
        @Binding var brands: [TaggedBrand]            // ★ 추가
        @FocusState.Binding var focusedField: Field?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("브랜드 입력").font(.suit(.bold, size: 18)).foregroundStyle(Color.contentBase)
                    Spacer()
                    Text("\(brands.count)개/3개").font(.suit(.light, size: 14)).foregroundStyle(Color.contentAssistive)
                }
                .padding(.top, 10).padding(.bottom, 6)
                
                TextEditor(text: $brandInput)
                    .customStyleEditor(placeholder: "태그할 브랜드를 입력해주세요", userInput: $brandInput, maxLength: nil)
                    .frame(height: 48)
                    .focused($focusedField, equals: .brand)
                    .padding(.vertical, 8)
                    .onChange(of: brandInput) { _, newValue in
                        handleBrandInputChange(newValue)
                    }
                
                if !brandSuggestions.isEmpty {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(brandSuggestions, id: \.keyword) { suggestion in
                                BrandSuggestionRow(suggestion: suggestion) {
                                    if !brands.contains(where: { $0.name == suggestion.keyword }), brands.count < 3 {
                                        brands.append(TaggedBrand(name: suggestion.keyword, imageUrl: suggestion.imageUrl))
                                    }
                                    brandInput = ""
                                    brandSuggestions = []
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 200)
                }
                
                if !brands.isEmpty {
                    Text("태그된 브랜드").font(.suit(.light, size: 14)).foregroundStyle(Color.contentBase)
                        .padding(.top, 10).padding(.bottom, 6)
                    
                    HStack(spacing: 8) {
                        ForEach(brands) { tag in
                            HStack(spacing: 6) {
                                AsyncImage(url: URL(string: tag.imageUrl)) { img in
                                    img.resizable()
                                } placeholder: {
                                    Image("emptyBrand").resizable()
                                }
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                                Text(tag.name)
                                    .font(.suit(.medium, size: 14))
                                    .foregroundStyle(Color.contentAdditive)
                                Button {
                                    brands.removeAll { $0.id == tag.id }
                                } label: {
                                    Image("close")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 16)
        }
        
        private func handleBrandInputChange(_ newValue: String) {
            if newValue.contains("\n") {
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty, !viewModel.brands.contains(trimmed), viewModel.brands.count < 3 {
                    viewModel.brands.append(trimmed)
                }
                brandInput = ""
                brandSuggestions = []
            } else {
                Task {
                    do {
                        let results = try await AutoCompleteAPITarget.fetchBrandAutoComplete(keyword: newValue)
                        brandSuggestions = results
                    } catch {
                        brandSuggestions = []
                    }
                }
            }
        }
    }
    
    private struct ShopTagSection: View {
        @ObservedObject var viewModel: PostUploadViewModel
        @Binding var shopInput: String
        @Binding var shopSuggestions: [AutoCompleteShopDTO]
        @Binding var taggedShop: TaggedShop?
        @FocusState.Binding var focusedField: Field?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("빈티지샵 태그").font(.suit(.bold, size: 18)).foregroundStyle(Color.contentBase)
                    Spacer()
                    Text(taggedShop == nil ? "0개/1개" : "1개/1개").font(.suit(.light, size: 14)).foregroundStyle(Color.contentAssistive)
                }
                .padding(.top, 10).padding(.bottom, 6)
                
                TextEditor(text: $shopInput)
                    .customStyleEditor(placeholder: "태그할 샵 이름을 입력해주세요", userInput: $shopInput, maxLength: nil)
                    .frame(height: 48)
                    .focused($focusedField, equals: .shop)
                    .padding(.vertical, 8)
                    .onChange(of: shopInput) { _, newValue in
                        handleShopInputChange(newValue)
                    }
                
                if !shopSuggestions.isEmpty {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(shopSuggestions, id: \.name) { suggestion in
                                ShopSuggestionRow(suggestion: suggestion) {
                                    taggedShop = TaggedShop(name: suggestion.name, imageUrl: suggestion.imageUrl, address: suggestion.address)
                                    shopInput = ""
                                    shopSuggestions = []
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 200)
                }
                
                if let tag = taggedShop {
                    Text("태그된 샵").font(.suit(.light, size: 14)).foregroundStyle(Color.contentBase)
                        .padding(.top, 10).padding(.bottom, 6)
                    
                    HStack(spacing: 8) {
                        AsyncImage(url: URL(string: tag.imageUrl)) { img in
                            img.resizable()
                        } placeholder: {
                            Image("emptyImage").resizable()
                        }
                        .frame(width:40,height:40)
                        .clipShape(Circle())
                        VStack(alignment: .leading, spacing:2){
                            Text(tag.name)
                                .font(.suit(.medium, size: 18))
                                .foregroundStyle(Color.contentBase)
                            Text(tag.address)
                                .font(.suit(.light, size: 12))
                                .foregroundStyle(Color.contentAdditive)
                        }
                        Spacer()
                        Button {
                            taggedShop = nil
                        } label: {
                            Image("remove").resizable().frame(width:20,height:20)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 16)
        }
        
        private func handleShopInputChange(_ newValue: String) {
            if newValue.contains("\n") {
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    // For now, just clear input -- can't construct TaggedShop from string
                }
                shopInput = ""
                shopSuggestions = []
            } else {
                Task {
                    do {
                        shopSuggestions = try await AutoCompleteAPITarget.fetchShopAutoComplete(keyword: newValue)
                    } catch {
                        shopSuggestions = []
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Components (Tag Views)
    
    private static func BrandTagComponent(tag: String, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(tag)
                .font(.suit(.medium, size: 14))
                .foregroundStyle(Color.contentAdditive)
            
            Button(action: onDelete) {
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
    
    private static func ShopTagComponent(tag: String, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image("emptyImage")
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(tag)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.contentBase)
                Text("샵주소")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.contentAdditive)
            }
            Spacer()
            Button(action: onDelete) {
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

// MARK: - Logic
private extension PostUploadView {
    func uploadPost() {
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
                shopId: nil, // TODO: Map shoptag to ID
                styleId: nil, // TODO: Map selectedStyles to IDs
                brandId: nil // TODO: Map brands to IDs
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
    }
}



struct ImageThumb: View {
    let index: Int
    let image: UIImage
    let onDelete: (Int) -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(4)
            
            Button(action: {
                onDelete(index)
            }) {
                Image("imageDelete")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
        }
    }
}
