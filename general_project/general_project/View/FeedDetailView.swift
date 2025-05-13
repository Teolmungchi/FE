//
//  FeedDetailView.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct FeedDetailView: View {
    let feed: Feed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KFImage.url(URL(string: feed.fileName ?? ""))
                    .placeholder {
                        ProgressView()
                            .frame(height: 220)
                    }
                    .retry(maxCount: 2, interval: .seconds(3))
                    .cacheOriginalImage()
                    .fade(duration: 0.3)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    Text(feed.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 16)

                    Text(feed.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Divider().padding(.vertical, 10)

                    Text("분실장소 정보")
                        .font(.headline)
                        .padding(.bottom, 6)
                    HStack {
                        Text("분실날짜").fontWeight(.semibold)
                        Spacer()
                        Text(feed.lostDate ?? "-")
                    }
                    HStack {
                        Text("분실장소").fontWeight(.semibold)
                        Spacer()
                        Text(feed.lostPlace ?? "-")
                    }
                    HStack {
                        Text("특징").fontWeight(.semibold)
                        Spacer()
                        Text(feed.placeFeature ?? "-")
                    }

                    Divider().padding(.vertical, 10)

                    Text("분실동물 정보")
                        .font(.headline)
                        .padding(.bottom, 6)
                    HStack {
                        Text("품종").fontWeight(.semibold)
                        Spacer()
                        Text(feed.dogType ?? "-")
                    }
                    HStack {
                        Text("나이").fontWeight(.semibold)
                        Spacer()
                        Text("\(feed.dogAge ?? 0)")
                    }
                    HStack {
                        Text("성별").fontWeight(.semibold)
                        Spacer()
                        Text(feed.dogGender ?? "-")
                    }
                    HStack {
                        Text("색상").fontWeight(.semibold)
                        Spacer()
                        Text(feed.dogColor ?? "-")
                    }
                    HStack {
                        Text("특징").fontWeight(.semibold)
                        Spacer()
                        Text(feed.dogFeature ?? "-")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}
