//
//  FeedEditViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/15/25.
//

import SwiftUI

@MainActor
class FeedEditViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var presignedUrl: String
    @Published var lostDate: Date
    @Published var lostPlace: String
    @Published var placeFeature: String
    @Published var dogType: String
    @Published var dogAge: String
    @Published var dogGender: String
    @Published var dogColor: String
    @Published var dogFeature: String

    @Published var isSaving = false
    @Published var saveError: String?

    private let detailVM: FeedDetailViewModel

    init(detailVM: FeedDetailViewModel) {
        self.detailVM = detailVM
        let f = detailVM.feed

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let parsedDate = df.date(from: f.lostDate ?? "") ?? Date()

        // 초기값 세팅
        self.title        = f.title
        self.content      = f.content
        self.presignedUrl     = f.presignedUrl ?? ""
        self.lostDate     = parsedDate
        self.lostPlace    = f.lostPlace   ?? ""
        self.placeFeature = f.placeFeature ?? ""
        self.dogType      = f.dogType     ?? ""
        self.dogAge       = f.dogAge.map(String.init) ?? ""
        self.dogGender    = f.dogGender   ?? ""
        self.dogColor     = f.dogColor     ?? ""
        self.dogFeature   = f.dogFeature   ?? ""
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let lostDateStr = df.string(from: lostDate)

        let updated = Feed(
            id: detailVM.feed.id,
            author: detailVM.feed.author,
            title: title,
            content: content,
            presignedUrl: presignedUrl.isEmpty ? nil : presignedUrl,
            lostDate: lostDateStr,
            lostPlace: lostPlace.isEmpty ? nil : lostPlace,
            placeFeature: placeFeature.isEmpty ? nil : placeFeature,
            dogType: dogType.isEmpty ? nil : dogType,
            dogAge: Int(dogAge) ?? 0,
            dogGender: dogGender.isEmpty ? nil : dogGender,
            dogColor: dogColor.isEmpty ? nil : dogColor,
            dogFeature: dogFeature.isEmpty ? nil : dogFeature,
            likesCount: detailVM.feed.likesCount,
            createdAt: detailVM.feed.createdAt
        )

        await detailVM.updateFeed(with: updated)

        if let err = detailVM.errorMessage {
            saveError = err
        }
    }
}
