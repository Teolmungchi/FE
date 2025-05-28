//
//  ReportView.swift
//  general_project
//
//  Created by 이상엽 on 5/16/25.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var vm = ReportViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage("shouldRefreshFeed") private var shouldRefreshFeed = false
    @State private var showCameraPicker = false
    @State private var showImageOptions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // 헤더 섹션
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("동물 발견 신고")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("발견한 동물의 사진을 업로드하여 주인을 찾아주세요")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        
                        // 진행 상태 표시
                        ProgressIndicator(
                            currentStep: vm.selectedImage != nil ? 2 : 1,
                            totalSteps: 2,
                            stepTitles: ["사진 선택", "신고 완료"]
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // 이미지 선택 섹션
                    VStack(alignment: .leading, spacing: 20) {
                        ReportSectionHeader(
                            icon: "camera.fill",
                            title: "사진 선택",
                            subtitle: "발견한 동물의 사진을 선택해주세요"
                        )
                        
                        if let img = vm.selectedImage {
                            ImageDisplayCard(
                                image: img,
                                onRemove: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        vm.removeSelectedImage()
                                    }
                                },
                                onReplace: {
                                    showImageOptions = true
                                }
                            )
                        } else {
                            ImageSelectionCard(
                                onCameraSelected: {
                                    showCameraPicker = true
                                },
                                onPhotoSelected: {
                                    vm.showPhotoPicker = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    
                    // 안내 정보 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        ReportSectionHeader(
                            icon: "info.circle.fill",
                            title: "신고 안내",
                            subtitle: nil
                        )
                        
                        VStack(spacing: 12) {
                            InfoCard(
                                icon: "checkmark.circle.fill",
                                title: "명확한 사진",
                                description: "동물의 모습이 선명하게 보이면 좋아요",
                                color: .green
                            )
                            
                            InfoCard(
                                icon: "clock.fill",
                                title: "빠른 처리",
                                description: "신고 후 즉시 주인에게 전달돼요",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("동물 신고")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            vm.showConfirmModal = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14))
                            Text("신고하기")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(vm.selectedImage != nil ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(vm.selectedImage != nil ? Color.red : Color.gray.opacity(0.3))
                        )
                    }
                    .disabled(vm.selectedImage == nil)
                }
            }
            .actionSheet(isPresented: $showImageOptions) {
                ActionSheet(
                    title: Text("사진 변경"),
                    message: Text("새로운 사진을 선택하는 방법을 선택해주세요"),
                    buttons: [
                        .default(Text("카메라")) {
                            showCameraPicker = true
                        },
                        .default(Text("앨범")) {
                            vm.showPhotoPicker = true
                        },
                        .cancel(Text("취소"))
                    ]
                )
            }
        }
        
        // Photo & Camera pickers
        .sheet(isPresented: $vm.showPhotoPicker) {
            PhotoPicker(images: Binding(
                get: { vm.selectedImage.map { [$0] } ?? [] },
                set: vm.onImagesChanged
            ))
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker(image: $vm.selectedImage)
        }
        
        // Confirm modal
        .overlay {
            if vm.showConfirmModal {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            vm.showConfirmModal = false
                        }
                    }
                
                EnhancedReportModalView(
                    selectedImage: vm.selectedImage,
                    onDismiss: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            vm.showConfirmModal = false
                        }
                    },
                    onConfirm: {
                        vm.sendReport()
                        vm.saveReportImage()
                        withAnimation {
                            vm.showConfirmModal = false
                        }
                        vm.showMatchSheet = true
                        vm.removeSelectedImage()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        
        // Error alert
        .alert("오류 발생", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
        
        // Report success handler
        .onChange(of: vm.reportSuccess) { oldValue, newValue in
            if newValue {
                shouldRefreshFeed = true
                dismiss()
            }
        }
        
        // Match result sheet
        .sheet(isPresented: $vm.showMatchSheet) {
            MatchResultView(
                response: vm.matchResponse,
                onDismiss: {
                    vm.showMatchSheet = false
                }
            )
        }
    }
}

// MARK: - Custom Components

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    let stepTitles: [String]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(1...totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            
            HStack {
                ForEach(0..<stepTitles.count, id: \.self) { index in
                    Text(stepTitles[index])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(index + 1 <= currentStep ? .blue : .gray)
                    
                    if index < stepTitles.count - 1 {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ReportSectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
            }
        }
    }
}

struct ImageSelectionCard: View {
    let onCameraSelected: () -> Void
    let onPhotoSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("사진을 선택해주세요")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button(action: onCameraSelected) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("카메라")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                }
                
                Button(action: onPhotoSelected) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("앨범")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
        )
    }
}

struct ImageDisplayCard: View {
    let image: UIImage
    let onRemove: () -> Void
    let onReplace: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                }
                .offset(x: 8, y: -8)
            }
            
            HStack(spacing: 12) {
                Button(action: onReplace) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("사진 변경")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("사진 선택 완료")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 2)
        )
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

struct EnhancedReportModalView: View {
    let selectedImage: UIImage?
    let onDismiss: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 헤더
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
                
                Text("신고 확인")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("선택한 사진으로 동물 발견을 신고하시겠습니까?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 이미지 미리보기
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // 버튼
            HStack(spacing: 12) {
                Button("취소") {
                    onDismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                )
                
                Button("신고하기") {
                    onConfirm()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red)
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 40)
    }
}

struct MatchResultView: View {
    let response: MatchResponse?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let response = response {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    Text("신고 완료")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(response.data.first?.message ?? "제보가 성공적으로 완료되었습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button("확인") {
                        onDismiss()
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .padding(.horizontal, 20)
                } else {
                    ProgressView("제보 결과 확인 중...")
                        .font(.system(size: 16))
                        .padding()
                }
            }
            .padding(.vertical, 40)
            .navigationTitle("신고 결과")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
