//
//  StorageService.swift
//  general_project
//
//  Created by 이상엽 on 5/21/25.
//

import SwiftUI

final class StorageService {
    func fetchStorageItems(completion: @escaping (Result<[StorageItem], StorageAPIError>) -> Void) {
        guard let url = URL(string: "https://tmc.kro.kr/api/v1/match") else {
            completion(.failure(StorageAPIError.invalidURL))
            return
        }
        guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(StorageAPIError.unauthorized))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let raw = String(data: data!, encoding: .utf8) {
                print("📥 Storage API Raw Response:\n\(raw)")
            }
            guard let data = data else {
                completion(.failure(StorageAPIError.custom("No data returned")))
                return
            }
            do {
                // Decode wrapper response to extract items array
                let wrapper = try JSONDecoder().decode(StorageResponse.self, from: data)
                let items = wrapper.data
                completion(.success(items))
            } catch {
                completion(.failure(StorageAPIError.decodingFailed))
            }
        }
        .resume()
    }
}
