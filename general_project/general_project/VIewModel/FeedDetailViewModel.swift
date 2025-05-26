//
//  FeedDetailViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/14/25.
//

import Foundation

@MainActor
class FeedDetailViewModel: ObservableObject {
    @Published var feed: Feed
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var deletionSuccess = false
    
    init(feed: Feed) {
        self.feed = feed
    }
    
    /// 게시글 수정
    func updateFeed(with updated: Feed) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let url = URL(string: "https://tmc.kro.kr/api/v1/feed/\(feed.id)") else {
            errorMessage = "잘못된 URL"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 토큰
        guard
            let tokenData = KeychainHelper.shared.retrieve(
                service: "com.syproj.general-project",
                account: "accessToken"
            ),
            let accessToken = String(data: tokenData, encoding: .utf8)
        else {
            errorMessage = "로그인 후 다시 시도하세요"
            return
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // 디버깅: URL / 헤더
        print("➡️ PUT \(url.absoluteString)")
        print("Headers:", request.allHTTPHeaderFields ?? [:])

        // Body 준비 (Codable로 바꾸는 게 더 안전)
        struct UpdateReq: Codable {
            let title: String
            let content: String
            let fileName: String?
            let lostDate: String?
            let lostPlace: String?
            let placeFeature: String?
            let dogType: String?
            let dogAge: Int?
            let dogGender: String?
            let dogColor: String?
            let dogFeature: String?
        }
        let reqBody = UpdateReq(
            title: updated.title,
            content: updated.content,
            fileName: updated.fileName,
            lostDate: updated.lostDate,
            lostPlace: updated.lostPlace,
            placeFeature: updated.placeFeature,
            dogType: updated.dogType,
            dogAge: updated.dogAge,
            dogGender: updated.dogGender,
            dogColor: updated.dogColor,
            dogFeature: updated.dogFeature
        )
        do {
            request.httpBody = try JSONEncoder().encode(reqBody)
            print("Body JSON:", String(data: request.httpBody!, encoding: .utf8)!)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                errorMessage = "수정 실패: 잘못된 응답"
                return
            }
            print("⬅️ StatusCode:", http.statusCode)
            print("ResponseBody:", String(data: data, encoding: .utf8) ?? "")

            guard (200..<300).contains(http.statusCode) else {
                let msg = String(data: data, encoding: .utf8) ?? "\(http.statusCode)"
                errorMessage = "수정 실패: \(msg)"
                return
            }

            // 성공
            feed = updated

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 게시글 삭제
    func deleteFeed() async {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let url = URL(string: "https://tmc.kro.kr/api/v1/feed/\(feed.id)") else {
            errorMessage = "잘못된 URL"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        guard
            let tokenData = KeychainHelper.shared.retrieve(
                service: "com.syproj.general-project",
                account: "accessToken"
            ),
            let accessToken = String(data: tokenData, encoding: .utf8)
        else {
            errorMessage = "로그인 후 다시 시도하세요"
            return
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "삭제 실패: 잘못된 응답 형태"
                return
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                errorMessage = "삭제 실패: 서버 오류 \(httpResponse.statusCode)"
                return
            }
            deletionSuccess = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
