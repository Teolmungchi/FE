//
//  ChatAPIError.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import Foundation

enum ChatAPIError: Error {
    case unauthorized
    case invalidURL
    case network(Error)
    case decoding(Error)
    case unexpectedStatusCode(Int)
}
