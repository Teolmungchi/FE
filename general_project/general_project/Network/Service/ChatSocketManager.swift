//
//  ChatSocketManager.swift
//  general_project
//
//  Created by 이상엽 on 5/13/25.
//

//
// ChatSocketManager.swift
//

import Foundation
import SocketIO

final class ChatSocketManager {
    static let shared = ChatSocketManager()
    private(set) var currentUserId: Int?

    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let str = try c.decode(String.self)
            if let date = fmt.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid date: \(str)")
        }
        return d
    }()

    // 콜백
    var onConnectSuccess: ((Int) -> Void)?
    var onError: ((String) -> Void)?
    var onJoinedRoom: ((Int) -> Void)?
    var onNewMessage: ((ChatMessage) -> Void)?

    private init() {}

    func connect() {
        guard
            let tokenData = KeychainHelper.shared
                .retrieve(service: "com.syproj.general-project", account: "accessToken"),
            let token = String(data: tokenData, encoding: .utf8)
        else {
            onError?("토큰이 없거나 잘못되었습니다.")
            return
        }

        // 1) WebSocket 엔드포인트에 '/socket.io' 경로를 명시
        let url = URL(string: "wss://tmc.kro.kr/socket.io")!

        manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),                // 내부 로그
                .forceWebsockets(true),    // Polling 없이 바로 WS only
                .reconnects(true),         // 재접속 시도
                .secure(true),             // TLS 보장
                .forceNew(true),           // 매번 새 연결
                .connectParams(["token": token])
            ]
        )

        socket = manager?.defaultSocket
        addHandlers()
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
        manager = nil
        socket = nil
        currentUserId = nil
    }

    private func addHandlers() {
        guard let socket = socket else { return }

        // low-level 이벤트 확인
        socket.on(clientEvent: .connect) { _, _ in
            print("✅ [Socket] .connect 이벤트 – status:", socket.status.rawValue)
        }
//        socket.on(clientEvent: .connect) { [weak self] _, _ in
//            print("✅ low-level .connect 이벤트 – status:", socket.status.rawValue)
//            // userId 모를 땐 기본값(-1) 사용
//            self?.currentUserId = -1
//            DispatchQueue.main.async {
//                self?.onConnectSuccess?(-1)
//            }
//        }
        socket.on(clientEvent: .disconnect) { data, _ in
            print("🔴 [Socket] .disconnect 이벤트 – data:", data)
        }
        socket.on(clientEvent: .error) { data, _ in
            print("💥 [Socket] .error 이벤트 – data:", data)
        }
        socket.on(clientEvent: .reconnect) { _, _ in
            print("🔄 [Socket] .reconnect 시도")
        }

        // 서버 커스텀 connectSuccess
        socket.on("connectSuccess") { [weak self] data, _ in
                print("⭐️ [Socket] connectSuccess raw data:", data)
                // data == [ { "userId": 11 } ] 형태여야 함
                guard
                    let dict = data.first as? [String: Any],
                    let userId = dict["userId"] as? Int
                else {
                    print("⚠️ connectSuccess 파싱 실패:", data)
                    return
                }
                print("👉 파싱된 userId:", userId)
                self?.currentUserId = userId

                DispatchQueue.main.async {
                    self?.onConnectSuccess?(userId)
                }
            }
//        socket.on("connectSuccess") { [weak self] data, _ in
//                print("⭐️ connectSuccess raw data:", data)
//                var userId: Int = -1
//
//                if let dict = data.first as? [String: Any],
//                   let uid = dict["userId"] as? Int {
//                    userId = uid
//                    print("👉 서버가 보내온 userId:", uid)
//                } else {
//                    print("ℹ️ connectSuccess payload 비어있음, 기본 userId(-1) 사용")
//                }
//
//                self?.currentUserId = userId
//                DispatchQueue.main.async {
//                    self?.onConnectSuccess?(userId)
//                }
//            }

        socket.on("error") { [weak self] data, _ in
            if let dict = data.first as? [String: Any],
               let msg = dict["message"] as? String {
                print("🚨 [Socket] 서버 error 이벤트:", msg)
                DispatchQueue.main.async { self?.onError?(msg) }
            }
        }

        socket.on("joinedRoom") { [weak self] data, _ in
            print("✅ [Socket] joinedRoom 이벤트:", data)
            guard
                let dict = data.first as? [String: Any],
                let roomId = dict["chatRoomId"] as? Int
            else { return }
            DispatchQueue.main.async { self?.onJoinedRoom?(roomId) }
        }

        socket.on("newMessage") { [weak self] data, _ in
                   print("📨 [Socket] newMessage raw:", data)
                   guard
                       let dict = data.first as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: dict)
                   else {
                       print("⚠️ newMessage JSON 변환 실패:", data)
                       return
                   }

                   do {
                       let msg = try self?.decoder.decode(ChatMessage.self, from: jsonData)
                       print("🟢 newMessage 디코딩 성공:", msg!)
                       DispatchQueue.main.async {
                           self?.onNewMessage?(msg!)
                           NotificationCenter.default.post(name: .didReceiveNewMessage, object: nil)
                       }
                   } catch {
                       print("⚠️ newMessage 디코딩 에러:", error)
                   }
               }
    }

    func joinRoom(roomId: Int) {
        print("🔄 emit joinRoom:", roomId)
        socket?.emit("joinRoom", ["chatRoomId": roomId])
    }

    func sendMessage(roomId: Int, message: String) {
        guard let socket = socket, socket.status == .connected else {
            print("⚠️ sendMessage 실패 – 소켓 연결 안됨, status:", socket?.status.rawValue ?? -1)
            return
        }
        print("🔄 emit sendMessage:", roomId, message)
        socket.emitWithAck("sendMessage", ["chatRoomId": roomId, "message": message])
            .timingOut(after: 5) { ack in
                print("🪪 sendMessage ackData:", ack)
            }
    }
}
