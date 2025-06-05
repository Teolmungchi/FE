//
//  ChatAPIError.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import Foundation

enum ChatAPIError: Error {
    case unauthorized                 // 토큰 없음/인증 실패
    case invalidURL                   // URL 생성 실패
    case encodingFailed               // Body 직렬화(JSONSerialization) 실패
    case network(Error)               // 네트워크 에러(요청 자체 실패)
    case invalidResponse              // 응답이 HTTPURLResponse 가 아님
    case unexpectedStatusCode(Int)    // 200~299 외의 상태 코드
    case decoding(Error)              // 응답 JSON 디코딩 실패
}
