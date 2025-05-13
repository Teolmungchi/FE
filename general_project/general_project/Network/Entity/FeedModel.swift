//
//  FeedModel.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import Foundation

struct FeedRequest: Codable {
    let title: String
    let content: String
    let fileName: [String]
    let lostDate: String
    let lostPlace: String
    let placeFeature: String
    let dogType: String
    let dogAge: Int
    let dogGender: String
    let dogColor: String
    let dogFeature: String
}

struct FeedResponse: Decodable {
    let httpStatus: Int
    let success: Bool
    let data: FeedData?
    let message: [String]?
    let error: String?
    let statusCode: Int?
}

struct FeedData: Decodable {
    let id: Int
    let author: Author
    let title: String
    let content: String
    let fileName: [String]
    let lostDate: String
    let lostPlace: String
    let placeFeature: String
    let dogType: String
    let dogAge: Int
    let dogGender: String
    let dogColor: String
    let dogFeature: String
    let likesCount: Int
    let createdAt: String
}

struct Author: Codable {
    let id: Int
}

struct PresignedURLResponse: Codable {
    let httpStatus: Int
    let success: Bool
    let data: PresignedURLData?
    let message: String?
    let statusCode: Int?
}

struct PresignedURLData: Codable {
    let url: String
}
