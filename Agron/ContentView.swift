//
//  ContentView.swift
//  Agron
//
//  Created by nmop on 10/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var hasSeenOnboarding = false
    @State private var hasSeenSubscription = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView {
                    // Onboarding completed, update the state
                    hasSeenOnboarding = true
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                }
                .onAppear {
                    // Check if user has seen onboarding
                    hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                }
                .onChange(of: hasSeenOnboarding) { _, newValue in
                    if newValue {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                }
            } else if !hasSeenSubscription {
                // Show subscription page after onboarding
                SubscriptionPage(onComplete:  {
                    // Subscription page completed (user can skip or subscribe)
                    hasSeenSubscription = true
                    UserDefaults.standard.set(true, forKey: "hasSeenSubscription")
                })
                .onAppear {
                    // Check if user has seen subscription page
                    hasSeenSubscription = UserDefaults.standard.bool(forKey: "hasSeenSubscription")
                }
            } else if authManager.isAuthenticated {
                MainDashboardView()
                    .onAppear {
                        // Refresh user data when dashboard appears
                        authManager.checkAuthStatus()
                    }
            } else {
                AuthView()
                    .onAppear {
                        // Clear any previous auth state when showing auth view
                        authManager.clearError()
                        authManager.clearSuccess()
                    }
            }
        }
        .onAppear {
            // Check onboarding and subscription status
            hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            hasSeenSubscription = UserDefaults.standard.bool(forKey: "hasSeenSubscription")
            subscriptionManager.checkSubscriptionStatus()
            authManager.checkAuthStatus()
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            // Handle authentication state changes
            if isAuthenticated {
                // User just logged in, ensure we're on the main dashboard
                print("User authenticated: \(authManager.currentUser?.name ?? "Unknown")")
            }
        }
        // iPad-specific layout adjustments
        .if(horizontalSizeClass == .regular) { content in
            content
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Extension to conditionally apply modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
