//
//  TabView.swift
//  general_project
//
//  Created by 이상엽 on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: selection == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            BView()
                .tabItem {
                    Image(systemName: selection == 1 ? "archivebox.fill" : "archivebox")
                    Text("Pay")
                }
                .tag(1)
            CView()
                .tabItem {
                    Image(systemName: selection == 2 ? "camera.fill" : "camera")
                    Text("Order")
                }
                .tag(2)
                .badge("!")
            CView()
                .tabItem {
                    Image(systemName: selection == 3 ? "bubble.fill" : "bubble")
                    Text("Shop")
                }
                .tag(3)
            MyInfoView()
                .tabItem {
                    Image(systemName: selection == 4 ? "gearshape.fill" : "gearshape")
                    Text("Other")
                }
                .tag(4)
        }
        .tint(.black)
        
        
    }
}

#Preview {
    ContentView()
}

struct AView: View {
    var body: some View {
        Text("Hello, A!")
    }
}
struct BView: View {
    var body: some View {
        Text("Hello, B!")
    }
}
struct CView: View {
    var body: some View {
        Text("Hello, C!")
    }
}
