//
//  UserModel.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import Foundation

struct UserInfoOuterResponse: Codable {
    let httpStatus: Int?
    let success: Bool?
    let data: UserInfoInnerResponse?
}

struct UserInfoInnerResponse: Codable {
    let httpStatus: Int?
    let success: Bool?
    let data: UserInfo?
}

struct UserInfo: Codable {
    let id: Int?
    let login_id: String?
    let name: String?
}
