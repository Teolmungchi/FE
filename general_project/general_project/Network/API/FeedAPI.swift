//
//  FeedAPI.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import Foundation

enum FeedAPI {
    static let baseURL = "https://tmc.kro.kr"
    
    static var createFeedURL: URL? {
        URL(string: "\(baseURL)/api/v1/feed")
    }
    
    static var presignedURL: URL? {
        URL(string: "\(baseURL)/api/v1/s3/upload")
    }
    
    static var feedListURL: URL? {
        URL(string: "\(baseURL)/api/v1/feed")
    }
}
