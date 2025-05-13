//
//  RootView.swift
//  general_project
//
//  Created by 이상엽 on 2/23/25.
//

import SwiftUI

struct RootView: View {
    @State private var showMainView = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    
    var body: some View {
        ZStack {
            if showMainView {
                if isLoggedIn {
                    if hasCompletedOnboarding {
                        ContentView()
                    } else {
                        OnboardingView() 
                    }
                } else {
                    SignInView()
                }
            } else {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showMainView = true
                            }
                        }
                    }
            }
        }
    }
}
