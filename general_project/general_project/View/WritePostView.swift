//
//  WritePostView.swift
//  general_project
//
//  Created by 이상엽 on 5/7/25.
//

import SwiftUI

struct WritePostView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var titleText: String = ""
    @State private var contentText: String = ""
    @State private var showLocationInfo: Bool = false
    @State private var lostDate: Date = Date()
    @State private var lostPlace: String = ""
    @State private var placeFeature: String = ""

    @State private var dogType: String = ""
    @State private var dogAge: String = ""
    @State private var dogGender: String = ""
    @State private var dogColor: String = ""
    @State private var dogFeature: String = ""

    @State private var showPhotoPicker: Bool = false
    @State private var showConfirmModal: Bool = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    let feedService = FeedService()
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 사진 선택 영역
                    VStack(alignment: .leading, spacing: 8) {
                        Text("사진 *")
                            .font(.subheadline)
                            .fontWeight(.bold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // 선택된 이미지 썸네일
                                ForEach(Array(selectedImages.enumerated()), id: \ .element) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)

                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }

                                // 사진 추가 버튼
                                Button(action: { showPhotoPicker = true }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            .frame(width: 80, height: 80)

                                        Image(systemName: "camera")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // 제목 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("제목 *")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        TextField("제목을 입력하세요", text: $titleText)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 8)
                            .overlay(Divider(), alignment: .bottom)
                    }

                    // 내용 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내용 *")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        TextEditor(text: $contentText)
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }

                    // 장소 정보
                    DisclosureGroup("장소 정보") {
                        VStack(alignment: .leading, spacing: 16) {
                            // 분실 날짜
                            DatePicker("실종 날짜", selection: $lostDate, displayedComponents: .date)
                                .datePickerStyle(.compact)

                            // 분실 장소
                            TextField("실종 장소를 입력하세요", text: $lostPlace)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                            TextField("장소 특징을 입력하세요", text: $placeFeature)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 4)
                    
                    DisclosureGroup("동물 정보") {
                        VStack(alignment: .leading, spacing: 16) {
                            // 분실 장소
                            TextField("품종을 입력하세요", text: $dogType)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                            TextField("나이", text: $dogAge)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                            TextField("성별", text: $dogGender)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                            TextField("색상", text: $dogColor)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                            TextField("특징", text: $dogFeature)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .overlay(Divider(), alignment: .bottom)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 4)
                }
                .padding()
            }
            .padding(.bottom, 80)
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(images: $selectedImages)
            }

            // 하단 버튼
            HStack() {
                
                Button("등록하기") {
                    withAnimation {
                        showConfirmModal = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            // 커스텀 모달
            if showConfirmModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showConfirmModal = false }
                    }

                RegisterModalView(
                    onDismiss: {
                        withAnimation { showConfirmModal = false }
                    },
                    onRegister: {
                        withAnimation { showConfirmModal = false }
                        registerFeed()
                        print("등록 액션 실행2")
                    }
                )
                .transition(.scale)
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("실종 동물 등록")
                        .font(.system(size: 20, weight: .bold))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
    }
    func registerFeed() {
           guard let image = selectedImages.first else {
               errorMessage = "사진은 한 장 이상 올리세요"
               return
           }
           isLoading = true
           errorMessage = nil

           // 1. Presigned URL 요청
           feedService.fetchPresignedURL { result in
               switch result {
               case .success(let presignedURL):
                   // 2. 이미지 S3 업로드
                   feedService.uploadImageToS3(image: image, presignedURL: presignedURL) { uploadResult in
                       switch uploadResult {
                       case .success(let fileName):
                           // 3. 피드 생성 요청
                           let dateFormatter = DateFormatter()
                           dateFormatter.dateFormat = "yyyy-MM-dd"
                           let lostDateString = dateFormatter.string(from: lostDate)

                           let feedRequest = FeedRequest(
                               title: titleText,
                               content: contentText,
                               fileName: [fileName],
                               lostDate: lostDateString,
                               lostPlace: lostPlace,
                               placeFeature: placeFeature,
                               dogType: dogType,
                               dogAge: Int(dogAge) ?? 0,
                               dogGender: dogGender,
                               dogColor: dogColor,
                               dogFeature: dogFeature
                           )
                           feedService.createFeed(request: feedRequest) { createResult in
                               DispatchQueue.main.async {
                                   isLoading = false
                                   switch createResult {
                                   case .success(_):
                                       // 성공 처리 (예: 알림, 화면 이동)
                                       dismiss()
                                   case .failure(let error):
                                       errorMessage = error.localizedDescription
                                   }
                               }
                           }
                       case .failure(let error):
                           DispatchQueue.main.async {
                               isLoading = false
                               errorMessage = error.localizedDescription
                           }
                       }
                   }
               case .failure(let error):
                   DispatchQueue.main.async {
                       isLoading = false
                       errorMessage = error.localizedDescription
                   }
               }
           }
       }
}
