//
//  MainView.swift
//  general_project
//
//  Created by 이상엽 on 3/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var navigateToWritePost = false
    @State private var petList: [Feed] = []
    @State private var errorMessage: String?
    let feedService = FeedService()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List(petList) { feed in
                    NavigationLink(destination: FeedDetailView(feed: feed)) {
                        HomeFeedRow(feed: feed)
                    }
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("실종 동물 찾기")
                            .font(.system(size: 20, weight: .bold))
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button { } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        }
                        Button { } label: {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToWritePost) {
                    WritePostView()
                }
                Button(action: {
                    navigateToWritePost = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadFeeds()
        }
    }

    func loadFeeds() {
        print("loadFeeds called")
        feedService.fetchFeeds { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let feeds):
                    print("피드 불러오기 성공: \(feeds.count)개")
                    self.petList = feeds
                case .failure(let error):
                    print("피드 불러오기 실패: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
