//
//  StorageViewModel.swift
//  general_project
//
//  Created by 이상엽 on 5/21/25.
//

import SwiftUI

@MainActor
final class StorageViewModel: ObservableObject {
    @Published var items: [StorageItem] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let service = StorageService()

    func loadItems() {
        print("fetchStorageItems호출")
        isLoading = true
        service.fetchStorageItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    print("매칭 리스트 조회 성공")
                    self?.items = items
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("매칭 리스트 조회 실패: \(self?.errorMessage)")

                }
            }
        }
    }
}
