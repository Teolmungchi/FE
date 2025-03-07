//
//  SignInView.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI
import PhotosUI

// 1) 회원가입 단계를 나타내는 열거형
enum SignUpStep {
    case enterID
    case enterPassword
    case enterNickname
    case uploadProfilePhoto
}

struct SignUpView: View {
    // 2) 현재 어떤 단계인지 저장
    @State private var currentStep: SignUpStep = .enterID
    
    // 3) 회원가입에 필요한 데이터
    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var nickname: String = ""
    @State private var profileImage: Image? = nil
    
    // 실제로는 UIImage나 Data를 저장해서 서버로 보내는 식으로 할 수도 있음
    // @State private var profileUIImage: UIImage? = nil
    
    // 사용자가 고른 사진 정보를 저장할 변수 (PhotosPickerItem)
    @State private var selectedItem: PhotosPickerItem?
    
    // 선택된 이미지 데이터를 담을 변수
    @State private var selectedImageData: Data?
    
    var body: some View {
        VStack {
            Spacer()
            
            // 4) 단계별로 다른 UI를 보여주기
            switch currentStep {
            case .enterID:
                UnderlinedTextField(label: "아이디", text: $userId)
                    .padding(.horizontal, 40)
                
            case .enterPassword:
                UnderlinedTextField(label: "비밀번호", text: $password, isSecure: true)
                    .padding(.horizontal, 40)
                
            case .enterNickname:
                UnderlinedTextField(label: "닉네임", text: $nickname)
                    .padding(.horizontal, 40)
                
            case .uploadProfilePhoto:
                // 이미지 미리보기
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        // 아직 선택 안 했으면 회색 원
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.brown)
                                    .offset(x: 40, y: 40)
                            )
                    }
                }
                .onChange(of: selectedItem) { oldItem, newItem in
                    Task {
                        if let newItem,
                           let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
            }
            
            Spacer()
            
            // 5) 하단에 '다음' 버튼, 혹은 '건너뛰기' 버튼
            VStack(spacing: 20) {
                // (프로필사진 단계에서만 '건너뛰기' 버튼 보이도록 할 수도 있음)
                if currentStep == .uploadProfilePhoto {
                    Button(action: {
                        // 건너뛰기 로직
                        completeSignUp()
                    }){
                        Text("건너뛰기")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 302)
                            .background(Color.brown)
                            .cornerRadius(50)
                    }
                }
                
                Button(action: {
                    goToNextStep()
                }){
                    Text("다음")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 302)
                        .background(Color.brown)
                        .cornerRadius(50)
                    
                }
                .padding(.bottom, 40)
            }
            .background(Color.white.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
    
    // 단계 진행 함수
    private func goToNextStep() {
        switch currentStep {
        case .enterID:
            currentStep = .enterPassword
        case .enterPassword:
            currentStep = .enterNickname
        case .enterNickname:
            currentStep = .uploadProfilePhoto
        case .uploadProfilePhoto:
            // 최종 회원가입 완료 처리
            completeSignUp()
        }
    }
    
    // 회원가입 완료 처리 (서버 통신 등)
    private func completeSignUp() {
        print("회원가입 완료 - userId: \(userId), password: \(password), nickname: \(nickname)")
        // 실제 회원가입 로직 구현
    }
}

// 미리보기
struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
