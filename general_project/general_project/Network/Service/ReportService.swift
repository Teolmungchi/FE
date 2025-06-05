//
//  ReportService.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import SwiftUI

class ReportService {
    func fetchAllURLs(completion: @escaping (Result<[AllURLItem], ReportAPIError>) -> Void) {
        guard let url = ReportAPI.allURL else {
            completion(.failure(.invalidURL))
            return
        }
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
                print("🚨 Network error:", error)
                completion(.failure(.requestFailed))
                return
            }
            
            if let http = response as? HTTPURLResponse {
                print("🛰 Status code:", http.statusCode)
                print("🛰 Response headers:", http.allHeaderFields)
            }
            
            guard let data = data else {
                print("🚨 No data")
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(AllURLResponseModel.self, from: data)
                print("✅ Decoded AllURLResponseModel:")
                
                if decoded.success {
                    completion(.success(decoded.data))
                } else {
                    let message = "응답은 success=false"
                    print("⚠️", message)
                    completion(.failure(.custom(message)))
                }
            } catch {
                print("❌ Decoding AllURLResponseModel failed:", error)
                completion(.failure(.decodingFailed))
            }
        }
        .resume()
    }
    
    func sendReport(
        images: [ReportImage],
        originImageData: Data,
        completion: @escaping (Result<ReportResponse, ReportAPIError>) -> Void
    ) {
        guard let url = ReportAPI.predictURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("69420", forHTTPHeaderField: "ngrok-skip-browser-warning")
        var body = Data()
        
        // JSON part
        let jsonData = try! JSONEncoder().encode(images)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(jsonData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Image part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"origin_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(originImageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Boundary 마무리
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 디버깅 로그
        let bodyData = body
        let imageHeaderString = "Content-Disposition: form-data; name=\"origin_image\"; filename=\"image.jpg\""
        if let bodyText = String(data: bodyData, encoding: .isoLatin1),
           bodyText.contains(imageHeaderString) {
            print("✅ origin_image 파트 헤더 발견!")
        }
        
        // 요청 보내기
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [sendReport] network error:", error.localizedDescription)
                return completion(.failure(.requestFailed))
            }
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ [sendReport] not HTTPURLResponse")
                return completion(.failure(.invalidResponse))
            }
            
            print("📡 [sendReport] statusCode:", http.statusCode)
            
            guard let data = data else {
                print("❌ [sendReport] response body 없음")
                return completion(.failure(.invalidResponse))
            }
            
            if (200..<300).contains(http.statusCode) {
                do {
                    let decoded = try JSONDecoder().decode(ReportResponse.self, from: data)
                    print("✅ [sendReport] 응답 디코딩 성공:", decoded)
                    completion(.success(decoded))
                } catch {
                    print("❌ [sendReport] 디코딩 실패:", error)
                    completion(.failure(.custom("응답 디코딩 실패")))
                }
            } else {
                let msg = String(data: data, encoding: .utf8) ?? "\(http.statusCode)"
                print("⚠️ [sendReport] server error:", msg)
                completion(.failure(.custom(msg)))
            }
        }.resume()
    }
    
    func sendMatchResult(
        from response: ReportResponse,
        completion: @escaping (Result<MatchResponse, ReportAPIError>) -> Void
    ) {
        guard let url = ReportAPI.matchURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(.unauthorized))
            return
        }
        
        let matchResults: [MatchResult] = response.results.compactMap { result in
            guard let authorId = Int(result.authorId),
                  let feedId = Int(result.feedId)
            else {
                return nil
            }
            
            return MatchResult(
                authorId: authorId,
                feedId: feedId,
                similarityScore: Float(result.similarityScore)
            )
        }
        
        let payload = MatchRequest(results: matchResults)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let bodyData = try JSONEncoder().encode(payload)
            if let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📤 sendMatchRequest body:\n\(bodyString)")
            }
            request.httpBody = bodyData
        } catch {
            completion(.failure(.encodingFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(.invalidResponse))
            }
            
            print("📡 [sendMatchResult] statusCode:", http.statusCode)
            
            guard (200..<300).contains(http.statusCode), let data = data else {
                let msg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "\(http.statusCode)"
                return completion(.failure(.custom(msg)))
            }
            
            do {
                let decoded = try JSONDecoder().decode(MatchResponse.self, from: data)
                print("✅ 매칭 응답 디코딩 성공:", decoded.data)
                completion(.success(decoded))
            } catch {
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ 디코딩 실패. 응답 원문:\n\(raw)")
                }
                completion(.failure(.custom("응답 디코딩 실패")))
            }        }.resume()
    }
    
    func saveReportImage(
        image: UIImage,
        completion: @escaping (Result<Void, ReportAPIError>) -> Void
    ) {
        let feedService = FeedService()
        // 0) 토큰 확보
        guard let tokenData = KeychainHelper.shared.retrieve(
                service: "com.syproj.general-project",
                account: "accessToken"
              ),
              let accessToken = String(data: tokenData, encoding: .utf8)
        else {
            print("❌ [saveReportImage] no access token")
            completion(.failure(.unauthorized))
            return
        }
        print("▶️ [saveReportImage] 시작")

        // 1) Presigned URL 요청
        feedService.fetchPresignedURL { result in
            switch result {
            case .failure(let err):
                print("❌ [fetchPresignedURL] 실패:", err)
                completion(.failure(.custom(err.localizedDescription)))

            case .success(let presignedURL):
                print("✅ [fetchPresignedURL] 성공:", presignedURL)

                // 2) S3에 업로드
                guard let data = image.jpegData(compressionQuality: 0.8) else {
                    print("❌ [uploadImageToS3] imageData 생성 실패")
                    completion(.failure(.encodingFailed))
                    return
                }
                print("▶️ [uploadImageToS3] PUT \(presignedURL) - dataSize:", data.count)

                feedService.uploadImageToS3(image: image, presignedURL: presignedURL) { uploadResult in
                    switch uploadResult {
                    case .failure(let err):
                        print("❌ [uploadImageToS3] 실패:", err)
                        completion(.failure(.custom(err.localizedDescription)))

                    case .success(let fileName):
                        print("✅ [uploadImageToS3] 성공, fileName:", fileName)

                        // 3) 서버에 fileName 저장
                        guard let url = ReportAPI.reportImageURL else {
                            print("❌ [saveReportImage] invalidURL")
                            return completion(.failure(.invalidURL))
                        }
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                        let payload = ReportImageRequestModel(fileName: fileName)
                        do {
                            let bodyData = try JSONEncoder().encode(payload)
                            request.httpBody = bodyData
                            if let jsonString = String(data: bodyData, encoding: .utf8) {
                                print("▶️ [saveReportImage] POST \(url)\nheaders: \(request.allHTTPHeaderFields ?? [:])\nbody:", jsonString)
                            }
                        } catch {
                            print("❌ [saveReportImage] JSON 인코딩 실패:", error)
                            return completion(.failure(.encodingFailed))
                        }

                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let err = error {
                                print("❌ [saveReportImage] network error:", err)
                                return completion(.failure(.requestFailed))
                            }
                            guard let http = response as? HTTPURLResponse else {
                                print("❌ [saveReportImage] invalidResponse")
                                return completion(.failure(.invalidResponse))
                            }
                            print("↩️ [saveReportImage] statusCode:", http.statusCode)
                            if let data = data,
                               let body = String(data: data, encoding: .utf8) {
                                print("↩️ [saveReportImage] response body:\n", body)
                            }
                            if (200..<300).contains(http.statusCode) {
                                print("🎉 [saveReportImage] 완료")
                                completion(.success(()))
                            } else {
                                let msg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "\(http.statusCode)"
                                print("⚠️ [saveReportImage] 서버 에러:", msg)
                                completion(.failure(.custom(msg)))
                            }
                        }
                        .resume()
                    }
                }
            }
        }
    }
}

