//
//  StorageModel.swift
//  general_project
//
//  Created by 이상엽 on 5/21/25.
//

import Foundation

struct StorageResponse: Codable {
    let httpStatus: Int
    let success: Bool
    let data: [StorageItem]
}

struct StorageItem: Identifiable, Codable, Hashable {
    let finderId: Int
    let message: String
    let presignedURL: URL
    let finderPresignedURL: URL
    var id = UUID()


    enum CodingKeys: String, CodingKey {
        case finderId
        case message
        case finderPresignedURL = "finder_presigned_url"
        case presignedURL = "presigned_url"
    }
}
