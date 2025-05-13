//
//  FeedDetailModel.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import Foundation

struct FeedAuthor: Codable, Identifiable {
    let id: Int
    let name: String?
}

struct Feed: Codable, Identifiable {
    let id: Int
    let author: FeedAuthor
    let title: String
    let content: String
    let fileName: String?
    let lostDate: String?
    let lostPlace: String?
    let placeFeature: String?
    let dogType: String?
    let dogAge: Int?
    let dogGender: String?
    let dogColor: String?
    let dogFeature: String?
    let likesCount: Int?
    let createdAt: String?
}

struct FeedListResponse: Codable {
    let httpStatus: Int?
    let success: Bool
    let data: [Feed]?
    let message: String?
    let error: String?
    let statusCode: Int?
}
