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
}


//API의 엔드포인트(URL 경로)를 관리
enum APIEndpoint {
    case signUp(id: String, password: String, name: String)
    case signIn(id: String, password: String)
    
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
     }



