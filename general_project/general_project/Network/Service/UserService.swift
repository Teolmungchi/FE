//
//  UserService.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import Foundation

final class UserService {
    
    func fetchUserInfo(completion: @escaping (Result<UserInfo, UserAPIError>) -> Void) {
        guard let url = UserAPI.userInfoURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 키체인에서 토큰 가져오기
        guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(.unauthorized))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("User Info 요청 에러: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(UserInfoOuterResponse.self, from: data)
                if let user = decoded.data?.data {
                    completion(.success(user))
                } else {
                    print("❗️응답은 왔지만 user가 nil임: \(decoded)")
                    completion(.failure(.unauthorized))
                }
            } catch {
                print("디코딩 실패: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON 원본 응답: \(jsonString)")
                }
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    func updateNickname(newName: String, completion: @escaping (Result<NicknameData, Error>) -> Void) {
        switch UserAPI.updateNicknameRequest(newName: newName) {
        case .failure(let apiError):
            completion(.failure(apiError))
            return
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(UserAPIError.requestFailed))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(NicknameResponse.self, from: data)
                        if decoded.success {
                            completion(.success(decoded.data))
                        } else {
                            completion(.failure(UserAPIError.requestFailed))
                        }
                    } catch {
                        completion(.failure(UserAPIError.decodingFailed))
                    }
                }
            }.resume()
        }
    }
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        switch UserAPI.changePasswordRequest(currentPassword: currentPassword, newPassword: newPassword) {
        case .failure(let apiError):
            completion(.failure(apiError))
            return
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(UserAPIError.requestFailed))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ChangePasswordResponse.self, from: data)
                        if decoded.success {
                            completion(.success(()))
                        } else {
                            completion(.failure(UserAPIError.requestFailed))
                        }
                    } catch {
                        completion(.failure(UserAPIError.decodingFailed))
                    }
                }
            }.resume()
        }
    }
}
