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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack{
                    Text("발견한 동물을 신고해주세요")
                        .font(.subheadline)
                        .padding(.top, 16)
                    Spacer()
                }

                HStack(spacing: 40) {
                    VStack {
                        Button {
                            showCameraPicker = true
                        } label: {
                            VStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 28))
                                Text("카메라")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }

                    VStack {
                        Button {
                            vm.showPhotoPicker = true
                        } label: {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 28))
                                Text("앨범")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }

                if let img = vm.selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .padding(.horizontal)
                        .contextMenu {
                            Button("삭제") {
                                vm.removeSelectedImage()
                            }
                        }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(Text("이미지를 선택해주세요")
                            .font(.caption)
                            .foregroundColor(.gray))
                        .padding(.horizontal)
                }

                Spacer()

            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("신고하기") {
                        withAnimation { vm.showConfirmModal = true }
                    }
                    .foregroundStyle(.red)
                    .disabled(vm.selectedImage == nil)
                }
            }
            .navigationTitle("동물 신고")

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
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ReportModalView(
                        onDismiss: {
                            withAnimation {
                                vm.showConfirmModal = false
                                vm.removeSelectedImage()
                            }
                        },
                        onRegister: {
                            vm.sendReport()
                            vm.saveReportImage()
                            vm.removeSelectedImage()
                        }
                    )
                    .frame(width: 300)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .transition(.scale)
                }
            }

            // Error alert
            .alert("오류", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
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
                if let response = vm.matchResponse {
                    VStack(spacing: 16) {
                        Text(response.data.first?.message ?? "제보가 완료되었습니다")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Button("확인") {
                            vm.showMatchSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ProgressView("제보 결과 로딩 중...")
                        .padding()
                }
            }
        }
    }
}
