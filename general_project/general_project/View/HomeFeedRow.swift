//
//  HomeFeedRow.swift
//  general_project
//
//  Created by 이상엽 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct HomeFeedRow: View {
    let feed: Feed

    var tags: [String] {
        [feed.lostPlace ?? "", feed.dogType ?? ""]
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
            VStack(alignment: .leading, spacing: 8) {
                // Kingfisher KFImage 사용
                KFImage.url(URL(string: feed.fileName ?? ""))
                    .placeholder {
                        ProgressView()
                    }
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                HStack(spacing: 8) {
                    Text(feed.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    ForEach(tags, id: \.self) { tag in
                        if !tag.isEmpty {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 14)
                                .background(Color.paleMint)
                                .cornerRadius(20)
                        }
                    }
                }
                Text(feed.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
