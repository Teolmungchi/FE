//
//  FeedEditView.swift
//  general_project
//
//  Created by 이상엽 on 5/14/25.
//

import SwiftUI

struct FeedEditView: View {
    @StateObject private var editVM: FeedEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false

    init(viewModel: FeedDetailViewModel) {
        _editVM = StateObject(wrappedValue: FeedEditViewModel(detailVM: viewModel))
    }

    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("제목",    text: $editVM.title)
                TextEditor(text: $editVM.content)
                    .frame(minHeight: 100)
            }

            Section("분실 장소") {
                DatePicker("분실 날짜", selection: $editVM.lostDate, displayedComponents: .date)
                TextField("분실 장소", text: $editVM.lostPlace)
                TextField("특징",     text: $editVM.placeFeature)
            }
            Section("분실 동물") {
                TextField("품종", text: $editVM.dogType)
                TextField("나이", text: $editVM.dogAge)
                    .keyboardType(.numberPad)
                TextField("성별", text: $editVM.dogGender)
                TextField("색상", text: $editVM.dogColor)
                TextField("특징", text: $editVM.dogFeature)
            }
        }
        .navigationTitle("게시글 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await editVM.save()
                        if editVM.saveError != nil {
                            showError = true
                        } else {
                            dismiss()
                        }
                    }
                } label: {
                    if editVM.isSaving {
                        ProgressView()
                    } else {
                        Text("저장")
                    }
                }
                .disabled(editVM.isSaving)
            }
        }
        // 에러 Alert
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(editVM.saveError ?? "")
        }
    }
}
