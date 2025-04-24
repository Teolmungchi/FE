import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode  // 이전 화면으로 돌아가기 위한 환경 변수
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if viewModel.currentStep == .enterID {
                        // 현재 첫 단계면 loginView로 돌아감 (화면 dismiss)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        viewModel.goToPreviousStep()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            Image("loginlogo")
            Spacer()
            
            switch viewModel.currentStep {
            case .enterID:
                UnderlinedTextField(label: "아이디", text: $viewModel.userId, placeholder: "이메일 형식으로 입력해주세요")
                    .padding(.horizontal, 40)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 4)
                        .padding(.horizontal, 40)
                }

            case .enterPassword:
                UnderlinedTextField(label: "비밀번호", text: $viewModel.password, isSecure: true, placeholder: "4글자 이상 20글자 이하로 입력해주세요")
                    .padding(.horizontal, 40)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 4)
                        .padding(.horizontal, 40)
                }

            case .enterNickname:
                UnderlinedTextField(label: "닉네임", text: $viewModel.nickname, placeholder: "2글자 이상 20글자 이하로 입력해주세요")
                    .padding(.horizontal, 40)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 4)
                        .padding(.horizontal, 40)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 302)
                    .background(.black)
                    .cornerRadius(50)
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $viewModel.showCompletionModal) {
            VStack(spacing: 20) {
                // 원하는 이미지
                Image("catImage") // 실제 프로젝트에 맞게 수정
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("회원가입이 완료되었습니다!")
                    .font(.headline)
                
                Button("완료") {
                    // 모달 닫고, 로그인 화면으로 돌아가기
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(width: 120)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .presentationDetents([.medium]) // sheet 높이 조절 (선택)
        }
        .navigationBarHidden(true)
    }
}


struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
