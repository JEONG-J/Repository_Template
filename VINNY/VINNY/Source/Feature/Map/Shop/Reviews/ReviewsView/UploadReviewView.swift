//
//  UploadReviewView.swift
//  VINNY
//
//  Created by 한태빈 on 8/14/25.
//
import SwiftUI
import PhotosUI

struct UploadReviewView: View {
    @EnvironmentObject var container: DIContainer
    
    init(container: DIContainer) {
        
    }
    @StateObject var viewModel = UploadReviewViewModel()
    
    /// 이미지 업로드 관련 상태
    @State private var showPhotosPicker = false // 포토 피커(이미지 선택 창) 표시 여부
    @State private var selectedItems: [PhotosPickerItem] = [] // 선택된 이미지 아이템들
    
    
    var body: some View {
        ZStack{
            Color.backFillStatic.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 상단 고정 바
                ZStack {
                    HStack {
                        Button (action: {
                            container.navigationRouter.pop()
                        }) {
                            Image("arrowBack")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                    Text("후기 작성")
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
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 4)
                                } else {
                                    ForEach(0..<viewModel.postImages.count, id: \.self) { index in
                                        Image(uiImage: viewModel.postImages[index])
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .padding(.vertical, 4)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            
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
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        
                        // MARK: - 내용 입력
                        Rectangle()
                            .frame(maxWidth: .infinity, minHeight: 4)
                            .foregroundStyle(Color.borderDividerRegular)
                            .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("후기 작성")
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
                        
                        // MARK: - 하단 고정 버튼(업로드)
                        Button(action: {
                            print("업로드")
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
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }
}
#Preview {
    let container = DIContainer()
    UploadReviewView(container: container)
        .environmentObject(container)
}
