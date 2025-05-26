//
//  StorageAPIError.swift
//  general_project
//
//  Created by 이상엽 on 5/21/25.
//

import Foundation

enum StorageAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unauthorized
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .requestFailed:
            return "요청에 실패했습니다. 네트워크 상태를 확인해주세요."
        case .decodingFailed:
            return "서버 응답을 해석하는 데 실패했습니다."
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요."
        case .custom(let msg):
            return msg
        }
    }
}
