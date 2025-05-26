//
//  StorageAPI.swift
//  general_project
//
//  Created by 이상엽 on 5/21/25.
//

import Foundation

enum StorageAPI {
    static let baseURL = "https://tmc.kro.kr"

    static var storageURL: URL? {
        URL(string: "\(baseURL)/api/v1/match/get")
    }
}
