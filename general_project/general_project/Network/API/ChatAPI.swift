//
//  ChatAPI.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

import SwiftUI

// ChatAPIProtocol 정의해서 테스트나 모킹에도 활용할 수 있게 분리
protocol ChatAPIProtocol {
    func fetchChatRooms(completion: @escaping (Result<[ChatRoom], ChatAPIError>) -> Void)
    func fetchMessages(roomId: Int, limit: Int, completion: @escaping (Result<[ChatMessage], ChatAPIError>) -> Void)
    func createChatRoom(user2Id: Int, completion: @escaping (Result<ChatRoom, ChatAPIError>) -> Void)
    func markAsRead(roomId: Int, completion: @escaping (Result<Void, ChatAPIError>) -> Void)
}

struct ChatAPI: ChatAPIProtocol {
    private let baseURL = URL(string: "https://tmc.kro.kr/api/v1/chat")!
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            guard let date = fmt.date(from: str) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date: \(str)"
                )
            }
            return date
        }
        return d
    }()

    // 토큰·헤더 세팅을 공통으로
    // ChatAPI.swift 안에
    private func makeRequest(path: String,
                             method: String = "GET",
                             queryItems: [URLQueryItem]? = nil,
                             body: Data? = nil) -> Result<URLRequest, ChatAPIError> {
        // 1) 토큰 가져오기
        guard let tokenData = KeychainHelper.shared
                .retrieve(service: "com.syproj.general-project", account: "accessToken"),
              let accessToken = String(data: tokenData, encoding: .utf8)
        else {
            return .failure(.unauthorized)
        }

        // 2) baseURL + path 조립
        let endpoint = baseURL.appendingPathComponent(path)
        guard var comps = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            return .failure(.invalidURL)
        }
        // 3) queryItems 붙이기
        comps.queryItems = queryItems

        guard let url = comps.url else {
            return .failure(.invalidURL)
        }
        print("⚙️ [ChatAPI] Request URL:", url.absoluteString)

        // 4) URLRequest 생성
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = body
        return .success(req)
    }

    func fetchChatRooms(completion: @escaping (Result<[ChatRoom], ChatAPIError>) -> Void) {
        let reqResult = makeRequest(path: "rooms")
        switch reqResult {
        case .failure(let err):
            print("🛑 fetchChatRooms → makeRequest 실패:", err)
            return completion(.failure(err))
        case .success(let req):
            print("✅ fetchChatRooms → makeRequest 성공, URL:", req.url!.absoluteString)
            URLSession.shared.dataTask(with: req) { data, resp, err in
                if let e = err {
                    print("🛑 dataTask network error:", e)
                    return completion(.failure(.network(e)))
                }
                guard let http = resp as? HTTPURLResponse else {
                    print("🛑 dataTask resp not HTTPURLResponse")
                    return completion(.failure(.unexpectedStatusCode(-1)))
                }
                print("🔔 dataTask statusCode:", http.statusCode)
                guard (200..<300).contains(http.statusCode),
                      let d = data else {
                    print("🛑 unexpectedStatusCode or empty data:", http.statusCode)
                    return completion(.failure(.unexpectedStatusCode(http.statusCode)))
                }
                do {
                    let rooms = try decoder.decode([ChatRoom].self, from: d)
                    print("✅ rooms 디코딩 성공:", rooms)
                    completion(.success(rooms))
                } catch {
                    print("🛑 디코딩 에러:", error)
                    completion(.failure(.decoding(error)))
                }
            }.resume()
        }
    }

    func fetchMessages(roomId: Int,
                       limit: Int,
                       completion: @escaping (Result<[ChatMessage], ChatAPIError>) -> Void) {
        // path와 limit 쿼리를 함께 넘김
        let query = [URLQueryItem(name: "limit", value: "\(limit)")]
        switch makeRequest(path: "room/\(roomId)/messages",
                           method: "GET",
                           queryItems: query) {
        case .failure(let err):
            print("🛑 fetchMessages makeRequest 실패:", err)
            return completion(.failure(err))
        case .success(let req):
            print("✅ fetchMessages → Request URL:", req.url!.absoluteString)
            URLSession.shared.dataTask(with: req) { data, resp, err in
                if let e = err {
                    print("🛑 fetchMessages 네트워크 오류:", e)
                    return completion(.failure(.network(e)))
                }
                guard let http = resp as? HTTPURLResponse else {
                    print("🛑 fetchMessages non-HTTP response")
                    return completion(.failure(.unexpectedStatusCode(-1)))
                }
                print("🔔 fetchMessages statusCode:", http.statusCode)
                guard (200..<300).contains(http.statusCode),
                      let d = data else {
                    print("🛑 fetchMessages 상태 코드 에러:", http.statusCode)
                    return completion(.failure(.unexpectedStatusCode(http.statusCode)))
                }
                do {
                    let msgs = try decoder.decode([ChatMessage].self, from: d)
                    print("✅ fetchMessages 디코딩 성공, 개수:", msgs.count)
                    completion(.success(msgs))
                } catch {
                    print("🛑 fetchMessages 디코딩 에러:", error)
                    completion(.failure(.decoding(error)))
                }
            }.resume()
        }
    }
    
    func createChatRoom(
        user2Id: Int,
        completion: @escaping (Result<ChatRoom, ChatAPIError>) -> Void
    ) {
        // 0) Body 직렬화
        let bodyDict = ["user2Id": user2Id]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict) else {
            print("❌ [createChatRoom] JSONSerialization 실패, body:", bodyDict)
            DispatchQueue.main.async {
                completion(.failure(.encodingFailed))
            }
            return
        }

        // 1) URLRequest 생성
        switch makeRequest(path: "room", method: "POST", body: bodyData) {
        case .failure(let err):
            print("❌ [createChatRoom] makeRequest 실패:", err)
            DispatchQueue.main.async {
                completion(.failure(err))
            }

        case .success(let request):
            // 디버그: 요청 정보 출력
            print("▶️ [createChatRoom] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            print("   headers:", request.allHTTPHeaderFields ?? [:])
            if let bodyString = String(data: bodyData, encoding: .utf8) {
                print("   body:", bodyString)
            }

            // 2) 네트워크 호출
            URLSession.shared.dataTask(with: request) { data, response, error in
                // 네트워크 에러
                if let err = error {
                    print("❌ [createChatRoom] 네트워크 에러:", err)
                    DispatchQueue.main.async {
                        completion(.failure(.network(err)))
                    }
                    return
                }

                // HTTP 상태 코드
                guard let http = response as? HTTPURLResponse else {
                    print("❌ [createChatRoom] HTTPURLResponse 아님:", response ?? "nil response")
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                    return
                }
                print("↩️ [createChatRoom] statusCode:", http.statusCode)

                // 응답 바디
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("↩️ [createChatRoom] response body:\n\(body)")
                }

                // 비정상 코드 분기
                guard (200..<300).contains(http.statusCode) else {
                    print("⚠️ [createChatRoom] unexpected status code:", http.statusCode)
                    DispatchQueue.main.async {
                        completion(.failure(.unexpectedStatusCode(http.statusCode)))
                    }
                    return
                }

                // 3) JSON 디코딩
                do {
                    let room = try decoder.decode(ChatRoom.self, from: data!)
                    print("✅ [createChatRoom] 디코딩 성공:", room)
                    DispatchQueue.main.async {
                        completion(.success(room))
                    }
                } catch {
                    print("❌ [createChatRoom] 디코딩 실패:", error)
                    DispatchQueue.main.async {
                        completion(.failure(.decoding(error)))
                    }
                }
            }
            .resume()
        }
    }

    func markAsRead(roomId: Int, completion: @escaping (Result<Void, ChatAPIError>) -> Void) {
        let path = "room/\(roomId)/read"
        switch makeRequest(path: path, method: "POST") {
        case .failure(let err): return completion(.failure(err))
        case .success(let req):
            URLSession.shared.dataTask(with: req) { _, resp, err in
                if let e = err { return completion(.failure(.network(e))) }
                guard let http = resp as? HTTPURLResponse,
                      (200..<300).contains(http.statusCode) else {
                    let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
                    return completion(.failure(.unexpectedStatusCode(code)))
                }
                print("✅ [ChatService] markRoomAsRead status:",
                             (resp as? HTTPURLResponse)?.statusCode ?? -1)
                completion(.success(()))
            }.resume()
        }
    }
}
