//
//  ReportAPI.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import Foundation

enum ReportAPI {
    static let AIBaseURL = "https://a730-210-119-237-102.ngrok-free.app"
    static let baseURL = "https://tmc.kro.kr"

    static var predictURL: URL? {
        URL(string: "\(AIBaseURL)/api/predict-all")
    }
    
    static var allURL: URL? {
        URL(string: "\(baseURL)/api/v1/feed/all-urls")
    }
    
    static var matchURL: URL? {
        URL(string: "\(baseURL)/api/v1/match")
    }
    
    static var reportImageURL: URL? {
        URL(string: "\(baseURL)/api/v1/match/report")
    }
}
