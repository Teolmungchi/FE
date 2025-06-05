//
//  ReportViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var referenceItems: [AllURLItem] = []
    @Published var isLoading      = false
    @Published var errorMessage   : String?
    @Published var reportSuccess  = false
    @Published var showPhotoPicker = false
    @Published var showConfirmModal = false
    @Published var showMatchSheet = false
    @Published var matchResponse: MatchResponse?


    private let service = ReportService()
    init() { fetchReferenceItems() }

    private func fetchReferenceItems() {
        service.fetchAllURLs { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items): self.referenceItems = items
                case .failure(let e):      self.errorMessage = e.localizedDescription
                }
            }
        }
    }

    func onImagesChanged(_ images: [UIImage]) {
        selectedImage = images.last
    }
    
    func removeSelectedImage() { selectedImage = nil }

    func sendReport() {
        print("🛠 sendReport() called, selectedImage:", selectedImage != nil)
        guard let img = selectedImage,
              let imageData = img.jpegData(compressionQuality: 0.8)
        else {
            errorMessage = "이미지를 선택해주세요"
            return
        }

        // referenceItems → ReportImage 배열로 매핑
        let reportImages = referenceItems.map {
            ReportImage(
                authorId:    String($0.authorId),
                feedId:      String($0.feedId),
                presignedURL: $0.presignedURL
            )
        }

        isLoading = true
        service.sendReport(
            images: reportImages,
            originImageData: imageData
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let reportResponse):
                    self?.reportSuccess = true
                    self?.service.sendMatchResult(from: reportResponse) { matchResult in
                                switch matchResult {
                                case .success(let matchResponse):
                                    print("💡 매칭 결과 전송 완료:\(matchResponse)")
                                    DispatchQueue.main.async {
//                                        self?.showMatchSheet = true
                                        self?.matchResponse = matchResponse
                                    }
                                case .failure(let err):
                                    DispatchQueue.main.async {
                                        self!.errorMessage = "매칭 전송 실패: \(err)"
                                    }
                                }
                            }
                case .failure(let e):
                    self?.errorMessage = e.localizedDescription
                }
            }
        }
    }
    
    func saveReportImage() {
        guard let img = selectedImage else {
            errorMessage = "이미지를 선택해주세요"
            return
        }
        isLoading = true
        service.saveReportImage(image: img) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let saveRespons):
                    DispatchQueue.main.async {
                        self?.reportSuccess = true
                        print("💡 매칭 결과 전송 완료:\(saveRespons)")
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print("서버에 신고 이미지 보내기 실패: \(err)")
                    }
                }
            }
        }
    }
}
