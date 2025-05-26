//
//  ReportModel.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import Foundation

struct ReportImage: Codable {
    let authorId: String
    let feedId: String
    let presignedURL: String

    enum CodingKeys: String, CodingKey {
        case authorId
        case feedId       = "feed_id"
        case presignedURL = "presigned_url"
    }
}

struct ReportRequestBody: Codable {
  let images: [ReportImage]
}

struct ReportEnvelope: Codable {
  let request     : ReportRequestBody
  let originImage : String

  enum CodingKeys: String, CodingKey {
    case request
    case originImage = "origin_image"
  }
}

struct ReportResponse: Codable {
    let results: [ReportResult]
}

struct ReportResult: Codable {
    let authorId: String
    let feedId: String
    let similarityScore: Double
    let isSamePet: Bool
    let error: String?

    enum CodingKeys: String, CodingKey {
        case authorId
        case feedId = "feed_id"
        case similarityScore = "similarity_score"
        case isSamePet = "is_same_pet"
        case error
    }
}

struct AllURLItem: Codable {
    let feedId: Int
    let authorId: Int
    let presignedURL: String

    enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case authorId
        case presignedURL = "presigned_url"
    }
}

struct AllURLResponseModel: Codable {
    let httpStatus: Int
    let success: Bool
    let data: [AllURLItem]
}

struct MatchRequest: Codable {
    let results: [MatchResult]
}

struct MatchResult: Codable {
    let authorId: Int
    let feedId: Int
    let similarityScore: Float

    enum CodingKeys: String, CodingKey {
        case authorId
        case feedId = "feed_id"
        case similarityScore = "similarity_score"
    }
}

struct MatchResponse: Codable {
    let httpStatus: Int
    let success: Bool
    let data: [MatchResponseData]
}

struct MatchResponseData: Codable {
    let feedId: Int
    let authorId: Int
    let reporterId: Int
    let similarity: Double
    let saved: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case authorId
        case reporterId
        case similarity
        case saved
        case message
    }
}

struct ReportImageRequestModel: Codable {
    let fileName: String
}
