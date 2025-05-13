//
//  FeedService.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import UIKit

class FeedService {
    // 1. Presigned URL 요청
       func fetchPresignedURL(completion: @escaping (Result<String, FeedAPIError>) -> Void) {
           guard let url = FeedAPI.presignedURL else {
               print("❌ [fetchPresignedURL] invalid URL")   // ← 디버그
               completion(.failure(.invalidURL))
               return
           }
           print("▶️ [fetchPresignedURL] GET \(url)")       // ← 디버그

           guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
                 let accessToken = String(data: tokenData, encoding: .utf8) else {
               print("❌ [fetchPresignedURL] no access token") // ← 디버그
               completion(.failure(.unauthorized))
               return
           }
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("❌ [fetchPresignedURL] network error:", error) // ← 디버그
                   completion(.failure(.requestFailed))
                   return
               }
               if let http = response as? HTTPURLResponse {
                   print("↩️ [fetchPresignedURL] statusCode:", http.statusCode) // ← 디버그
               }
               guard let data = data else {
                   print("❌ [fetchPresignedURL] no data") // ← 디버그
                   completion(.failure(.requestFailed))
                   return
               }
               do {
                   let decoded = try JSONDecoder().decode(PresignedURLResponse.self, from: data)
                   print("✅ [fetchPresignedURL] decoded:", decoded)           // ← 디버그
                   if let url = decoded.data?.url {
                       completion(.success(url))
                   } else {
                       print("❌ [fetchPresignedURL] server error:", decoded.message ?? "") // ← 디버그
                       completion(.failure(.custom(decoded.message ?? "Presigned URL 요청 실패")))
                   }
               } catch {
                   print("❌ [fetchPresignedURL] decoding error:", error) // ← 디버그
                   completion(.failure(.decodingFailed))
               }
           }.resume()
       }

       // 2. Presigned URL로 이미지 업로드
       func uploadImageToS3(image: UIImage, presignedURL: String, completion: @escaping (Result<String, Error>) -> Void) {
           guard let url = URL(string: presignedURL),
                 let imageData = image.jpegData(compressionQuality: 0.8) else {
               print("❌ [uploadImageToS3] invalid presignedURL or imageData") // ← 디버그
               completion(.failure(APIError.invalidURL))
               return
           }
           var request = URLRequest(url: url)
           request.httpMethod = "PUT"
           request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
           print("▶️ [uploadImageToS3] PUT \(url) - dataSize:", imageData.count) // ← 디버그

           URLSession.shared.uploadTask(with: request, from: imageData) { _, response, error in
               if let error = error {
                   print("❌ [uploadImageToS3] upload error:", error) // ← 디버그
                   completion(.failure(error))
                   return
               }
               if let http = response as? HTTPURLResponse {
                   print("↩️ [uploadImageToS3] statusCode:", http.statusCode) // ← 디버그
               }
               let fileName = presignedURL.components(separatedBy: "?").first ?? presignedURL
               print("✅ [uploadImageToS3] uploaded fileName:", fileName) // ← 디버그
               completion(.success(fileName))
           }.resume()
       }

       // 3. 피드 생성 요청
       func createFeed(request: FeedRequest, completion: @escaping (Result<FeedData, Error>) -> Void) {
           guard let url = FeedAPI.createFeedURL else {
               print("❌ [createFeed] invalid URL") // ← 디버그
               completion(.failure(APIError.invalidURL))
               return
           }
           print("▶️ [createFeed] POST \(url) body:", request) // ← 디버그

           guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
                 let accessToken = String(data: tokenData, encoding: .utf8) else {
               print("❌ [createFeed] no access token") // ← 디버그
               completion(.failure(FeedAPIError.unauthorized))
               return
           }
           var urlRequest = URLRequest(url: url)
           urlRequest.httpMethod = "POST"
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

           do {
               let bodyData = try JSONEncoder().encode(request)
               urlRequest.httpBody = bodyData
           } catch {
               print("❌ [createFeed] body encoding error:", error) // ← 디버그
               completion(.failure(error))
               return
           }

           URLSession.shared.dataTask(with: urlRequest) { data, response, error in
               if let response = response as? HTTPURLResponse, response.statusCode == 400,
                  let body = data.flatMap({ String(data: $0, encoding: .utf8) }) {
                   print("❗️ [createFeed] 400 error body:\n\(body)")
                   completion(.failure(APIError.requestFailed))
                   return
               }
               if let error = error {
                   print("❌ [createFeed] network error:", error) // ← 디버그
                   completion(.failure(error))
                   return
               }
               if let http = response as? HTTPURLResponse {
                   print("↩️ [createFeed] statusCode:", http.statusCode) // ← 디버그
               }
               guard let data = data else {
                   print("❌ [createFeed] no data") // ← 디버그
                   completion(.failure(APIError.requestFailed))
                   return
               }
               do {
                   let decoded = try JSONDecoder().decode(FeedResponse.self, from: data)
                   print("✅ [createFeed] decoded:", decoded) // ← 디버그
                   if decoded.success, let feed = decoded.data {
                       print("🎉 [createFeed] success feed id:", feed.id) // ← 디버그
                       completion(.success(feed))
                   } else {
                       print("❌ [createFeed] server error:", decoded.message ?? "") // ← 디버그
                       completion(.failure(FeedAPIError.custom(decoded.message?.first ?? "피드 등록 실패")))
                   }
               } catch {
                   print("❌ [createFeed] decoding error:", error) // ← 디버그
                   completion(.failure(error))
               }
           }.resume()
       }
    
    func fetchFeeds(completion: @escaping (Result<[Feed], Error>) -> Void) {
            guard let url = FeedAPI.feedListURL else {
                completion(.failure(APIError.invalidURL))
                return
            }
            // Keychain에서 토큰 가져오기
            guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
                  let accessToken = String(data: tokenData, encoding: .utf8) else {
                completion(.failure(APIError.unauthorized))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(APIError.requestFailed))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(FeedListResponse.self, from: data)
                    if decoded.success, let feeds = decoded.data {
                        completion(.success(feeds))
                    } else {
                        completion(.failure(FeedAPIError.custom(decoded.message ?? "피드 목록을 불러오지 못했습니다.")))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
}
