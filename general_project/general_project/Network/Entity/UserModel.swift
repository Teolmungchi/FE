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
    var id: Int?
    var login_id: String?
    var name: String?
}

struct NicknameResponse: Codable {
    let httpStatus: Int
    let success: Bool
    let data: NicknameData
}

struct NicknameData: Codable {
    let id: Int
    let name: String
}

struct ChangePasswordResponse: Codable {
    let httpStatus: Int
    let success: Bool
    let data: String?
}
