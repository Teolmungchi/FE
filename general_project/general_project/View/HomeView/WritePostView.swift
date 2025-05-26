//
//  WritePostView.swift
//  general_project
//
//  Created by 이상엽 on 5/7/25.
//

import SwiftUI

struct WritePostView: View {
    @AppStorage("shouldRefreshFeed") private var shouldRefreshFeed = false

    @State private var selectedImages: [UIImage] = []
    @State private var titleText: String = ""
    @State private var contentText: String = ""
    @State private var lostDate: Date = Date()
    @State private var lostPlace: String = ""
    @State private var placeFeature: String = ""
    @State private var dogType: String = ""
    @State private var dogAge: String = ""
    @State private var dogGender: String = ""
    @State private var dogColor: String = ""
    @State private var dogFeature: String = ""

    @State private var showPhotoPicker = false
    @State private var showConfirmModal = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    let feedService = FeedService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Image Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("사진 *")
                            .font(.subheadline).bold()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages.indices, id: \ .self) { idx in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: selectedImages[idx])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                        Button { selectedImages.remove(at: idx) }
                                        label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }
                                Button { showPhotoPicker = true } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "camera").font(.system(size: 24)).foregroundColor(.gray)
                                        )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // MARK: - Text Fields
                    Group {
                        LabeledTextField(label: "제목 *", placeholder: "제목을 입력하세요", text: $titleText)
                        LabeledTextEditor(label: "내용 *", text: $contentText, height: 120)
                    }

                    // MARK: - Place Info
                    DisclosureGroup("장소 정보") {
                        VStack(spacing: 16) {
                            DatePicker("실종 날짜", selection: $lostDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            LabeledTextField(label: "실종 장소", placeholder: "실종 장소를 입력하세요", text: $lostPlace)
                            LabeledTextField(label: "장소 특징", placeholder: "장소 특징을 입력하세요", text: $placeFeature)
                        }
                        .padding(.top, 8)
                    }

                    // MARK: - Animal Info
                    DisclosureGroup("동물 정보") {
                        VStack(spacing: 16) {
                            LabeledTextField(label: "품종", placeholder: "품종을 입력하세요", text: $dogType)
                            LabeledTextField(label: "나이", placeholder: "나이를 입력하세요", text: $dogAge)
                            LabeledTextField(label: "성별", placeholder: "성별을 입력하세요", text: $dogGender)
                            LabeledTextField(label: "색상", placeholder: "색상을 입력하세요", text: $dogColor)
                            LabeledTextField(label: "특징", placeholder: "특징을 입력하세요", text: $dogFeature)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }

            // MARK: - Error / Loading
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            if isLoading {
                ProgressView()
                    .padding()
            }

            // MARK: - Submit Button
            Button(action: { withAnimation { showConfirmModal = true } }) {
                Text("등록하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.cornerRadius(8))
                    .foregroundColor(.white)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("실종 동물 등록")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold)).foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(images: $selectedImages)
        }
        .overlay(
            Group {
                if showConfirmModal {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    RegisterModalView(
                        onDismiss: { withAnimation { showConfirmModal = false } },
                        onRegister: {
                            withAnimation { showConfirmModal = false }
                            registerFeed()
                        }
                    )
                    .transition(.scale)
                    .zIndex(1)
                }
            }
        )
    }

    private func registerFeed() {
        guard !selectedImages.isEmpty else {
            errorMessage = "사진은 한 장 이상 올리세요"
            return
        }
        isLoading = true
        errorMessage = nil

        feedService.fetchPresignedURL { result in
            switch result {
            case .success(let url):
                feedService.uploadImageToS3(image: selectedImages[0], presignedURL: url) { res in
                    handleUploadResult(res)
                }
            case .failure(let err):
                finishWithError(err.localizedDescription)
            }
        }
    }

    private func handleUploadResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let fileName):
            createFeed(with: fileName)
        case .failure(let err):
            finishWithError(err.localizedDescription)
        }
    }

    private func createFeed(with fileName: String) {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let request = FeedRequest(
            title: titleText,
            content: contentText,
            fileName: [fileName],
            lostDate: fmt.string(from: lostDate),
            lostPlace: lostPlace,
            placeFeature: placeFeature,
            dogType: dogType,
            dogAge: Int(dogAge) ?? 0,
            dogGender: dogGender,
            dogColor: dogColor,
            dogFeature: dogFeature
        )
        feedService.createFeed(request: request) { res in
            DispatchQueue.main.async {
                isLoading = false
                switch res {
                case .success:
                    shouldRefreshFeed = true; dismiss()
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func finishWithError(_ msg: String) {
        DispatchQueue.main.async {
            isLoading = false
            errorMessage = msg
        }
    }
}

// MARK: - Helper Views

private struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).bold()
            TextField(placeholder, text: $text)
                .padding(.vertical, 8)
                .overlay(Divider(), alignment: .bottom)
        }
    }
}

private struct LabeledTextEditor: View {
    let label: String
    @Binding var text: String
    let height: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).bold()
            TextEditor(text: $text)
                .frame(height: height)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.4)))
        }
    }
}
