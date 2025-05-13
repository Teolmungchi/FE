//
//  AuthAPI.swift
//  general_project
//
//  Created by 이상엽 on 3/7/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case decodingFailed
    case requestFailed
    case customError(String)
    case unauthorized
    case invalidResponse
    
    var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "유효하지 않은 URL입니다."
            case .requestFailed:
                return "요청에 실패했습니다. 네트워크 상태를 확인해주세요."
            case .decodingFailed:
                return "서버 응답을 해석하는 데 실패했습니다."
            case .unauthorized:
                return "잘못된 형식입니다. 다시 로그인해주세요."
            case .invalidResponse:
                return "서버 응답이 잘못되었습니다."
            case .customError(let message):
                return message

            }
        }
}


//API의 엔드포인트(URL 경로)를 관리
enum APIEndpoint {
    case signUp(id: String, password: String, name: String)
    case signIn(id: String, password: String)
    case logout
    
    //모든 API 요청의 기본 URL
    var baseURL: String {
        return "https://tmc.kro.kr"
    }
    
    //각 엔드포인트의 경로 설정
    //path는 기본 URL 뒤에 붙는 세부 경로
    var path: String {
        switch self {
        case .signUp:
            return "/api/v1/auth/sign-up"
        case .signIn:
            return "/api/v1/auth/login"
        case .logout:
            return "/api/v1/auth/logout"
        }
    }
    
    //URLComponent를 사용한 URL 생성
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path //경로 설정
        
        return components?.url //components?.url을 통해 URL 객체를 생성해.
    }
}

final class APIService {
    //서버에 새로운 Post데이터를 전송하는 함수
    //Post객체를 받아서 서버에 POST 요청을 보낼 준비
    func createUser(user: User, completion: @escaping (Result<SignUpResponse, APIError>) -> Void) {
        let endpoint = APIEndpoint.signUp(id: user.userId, password: user.password, name: user.name)
        
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        //URLRequest 설정
        //URLRequest 객체를 생성하고 POST 메서드를 설정
        //Content-Type을 application/json으로 설정해 JSON 형식임을 알려
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //HTTP Body 설정
        //JSONEncoder를 사용해 Post 객체를 JSON 데이터로 변환
        //변환된 데이터를 request.httpBody에 담아 서버로 전송할 준비
        do {
            let bodyData = try JSONEncoder().encode(user)
            request.httpBody = bodyData
        } catch {
            completion(.failure(.decodingFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Network error: \(error!.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                print("No data returned from server.")
                completion(.failure(.requestFailed))
                return
            }
            
            //POST 요청 응답 처리
            //서버에서 반환된 데이터를 Post객체로 디코딩
            do {
                let signUpResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                print("Decoded response: \(signUpResponse)")
                
                completion(.success(signUpResponse))
            } catch let decodeError {
                print("Decoding failed: \(decodeError.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    func Signin(userInfo: SignInRequest, completion: @escaping (Result<SignInResponse, APIError>) -> Void) {
        let endpoint = APIEndpoint.signIn(id: userInfo.userId, password: userInfo.password)
        
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        //URLRequest 설정
        //URLRequest 객체를 생성하고 POST 메서드를 설정
        //Content-Type을 application/json으로 설정해 JSON 형식임을 알려
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //HTTP Body 설정
        //JSONEncoder를 사용해 Post 객체를 JSON 데이터로 변환
        //변환된 데이터를 request.httpBody에 담아 서버로 전송할 준비
        do {
            let bodyData = try JSONEncoder().encode(userInfo)
            request.httpBody = bodyData
        } catch {
            completion(.failure(.decodingFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Network error: \(error!.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                print("No data returned from server.")
                completion(.failure(.requestFailed))
                return
            }
            
            //POST 요청 응답 처리
            //서버에서 반환된 데이터를 Post객체로 디코딩
            do {
                let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                print("Decoded response: \(signInResponse)")
                guard
                    let accessToken = signInResponse.data?.accessToken,
                    let refreshToken = signInResponse.data?.refreshToken
                else {
                    print("토큰이 없습니다.")
                    completion(.failure(.unauthorized)) // 또는 .invalidResponse 등 적절한 에러
                    return
                }

                // Keychain에 토큰 저장
                KeychainHelper.shared.save(Data(accessToken.utf8), service: "com.syproj.general-project", account: "accessToken")
                KeychainHelper.shared.save(Data(refreshToken.utf8), service: "com.syproj.general-project", account: "refreshToken")
                completion(.success(signInResponse))
            }catch let decodeError {
                print("Decoding failed: \(decodeError.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                // 여기서 message 파싱 시도
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.failure(.customError(message)))
                } else {
                    completion(.failure(.decodingFailed))
                }
            }


        }.resume()
    }

    func logout(completion: @escaping (Result<String, APIError>) -> Void) {
        let endpoint = APIEndpoint.logout

        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }

        guard let tokenData = KeychainHelper.shared.retrieve(service: "com.syproj.general-project", account: "accessToken"),
              let accessToken = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(.unauthorized))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                return
            }

            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(LogoutResponse.self, from: data)
                completion(.success(decoded.message))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}



