//
//  ReportAPIError.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//
import Foundation

enum ReportAPIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case decodingFailed
    case encodingFailed
    case unauthorized
    case custom(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL: return "유효하지 않은 URL입니다."
        case .requestFailed: return "요청에 실패했습니다."
        case .invalidResponse: return "서버 응답이 올바르지 않습니다."
        case .decodingFailed: return "응답 디코딩에 실패했습니다."
        case .encodingFailed: return "요청 인코딩에 실패했습니다."
        case .unauthorized: return "인증이 필요합니다. 다시 로그인해주세요."
        case .custom(let message): return message
        }
    }
}
