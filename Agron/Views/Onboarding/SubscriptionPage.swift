import SwiftUI
import StoreKit

struct SubscriptionPage: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showAuth = false
    @State private var selectedPlan: String?
    @State private var showFeatures = false
    var onSkip: (() -> Void)? = nil
    var onComplete: (() -> Void)? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: AppSpacing.lg) {
                        // Logo/Icon with animation
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.top, AppSpacing.xxl)
                        .scaleEffect(showFeatures ? 1.0 : 0.8)
                        .animation(.easeOut(duration: 0.6), value: showFeatures)
                        
                        VStack(spacing: AppSpacing.md) {
                            Text("Unlock Premium Features")
                                .font(AppTypography.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Join thousands of farmers, buyers, and transporters who are already growing their businesses with Agron Premium")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.lg)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Features Section
                    VStack(spacing: AppSpacing.lg) {
                        Text("Premium Features")
                            .font(AppTypography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppSpacing.md) {
                            FeatureCard(
                                icon: "leaf.fill",
                                title: "Unlimited Listings",
                                description: "List as many crops as you want",
                                color: AppColors.primary
                            )
                            
                            FeatureCard(
                                icon: "truck.box.fill",
                                title: "Priority Delivery",
                                description: "Get first access to delivery jobs",
                                color: AppColors.secondary
                            )
                            
                            FeatureCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Advanced Analytics",
                                description: "Detailed insights and metrics",
                                color: AppColors.accent
                            )
                            
                            FeatureCard(
                                icon: "bell.fill",
                                title: "Real-time Alerts",
                                description: "Instant notifications",
                                color: AppColors.info
                            )
                            
                            FeatureCard(
                                icon: "shield.fill",
                                title: "Premium Support",
                                description: "Priority customer support",
                                color: AppColors.success
                            )
                            
                            FeatureCard(
                                icon: "star.fill",
                                title: "Verified Badge",
                                description: "Stand out with verification",
                                color: AppColors.warning
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Subscription Plans
                    VStack(spacing: AppSpacing.lg) {
                        Text("Choose Your Plan")
                            .font(AppTypography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if subscriptionManager.isLoading {
                            VStack(spacing: AppSpacing.md) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .foregroundColor(AppColors.primary)
                                
                                Text("Loading plans...")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(AppSpacing.xl)
                        } else {
                            VStack(spacing: AppSpacing.md) {
                                // Weekly Plan
                                SubscriptionPlanCard(
                                    title: "Weekly Plan",
                                    price: "$3.99",
                                    period: "per week",
                                    features: ["3-day free trial", "Cancel anytime", "All premium features"],
                                    isPopular: false,
                                    isSelected: selectedPlan == "weekly",
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedPlan = "weekly"
                                        }
                                    }
                                )
                                
                                // Annual Plan
                                SubscriptionPlanCard(
                                    title: "Annual Plan",
                                    price: "$39.99",
                                    period: "per year",
                                    features: ["Save 80%", "Best value", "All premium features"],
                                    isPopular: true,
                                    isSelected: selectedPlan == "yearly",
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedPlan = "yearly"
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Action Buttons
                    VStack(spacing: AppSpacing.md) {
                        if let selectedPlan = selectedPlan {
                            PrimaryButton(
                                selectedPlan == "weekly" ? "Start Free Trial" : "Subscribe Now",
                                isLoading: subscriptionManager.isLoading
                            ) {
                                Task {
                                    if selectedPlan == "weekly" {
                                        await subscriptionManager.purchaseWeekly()
                                    } else {
                                        await subscriptionManager.purchaseYearly()
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        
                        Button(action: {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.top, AppSpacing.sm)
                        

                    }
                    .padding(.bottom, AppSpacing.lg)
                    
                    // Terms and Privacy
                    VStack(spacing: AppSpacing.sm) {
                        Text("By continuing, you agree to our")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: AppSpacing.xs) {
                            Button("Terms of Service") {
                                // Open terms
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.primary)
                            
                            Text("and")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Button("Privacy Policy") {
                                // Open privacy policy
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    showFeatures = true
                }
            }
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            if isSubscribed {
                UserDefaults.standard.set(true, forKey: "hasSeenSubscription")
                onComplete?()
            }
        }
        .alert("Error", isPresented: .constant(subscriptionManager.errorMessage != nil)) {
            Button("OK") {
                subscriptionManager.clearError()
            }
        } message: {
            Text(subscriptionManager.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showAuth) {
            AuthView()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .fill(AppColors.surface)
        )
        .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
    }
}

struct SubscriptionPlanCard: View {
    let title: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(title)
                            .font(AppTypography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        HStack(alignment: .bottom, spacing: AppSpacing.xs) {
                            Text(price)
                                .font(AppTypography.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                            
                            Text(period)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isPopular {
                        Text("BEST VALUE")
                            .font(AppTypography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColors.accent)
                            .cornerRadius(AppCornerRadius.sm)
                    }
                }
                
                // Features
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.success)
                            
                            Text(feature)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: isSelected ? AppColors.primary.opacity(0.2) : AppShadows.small.color, 
                   radius: isSelected ? 8 : AppShadows.small.radius, 
                   x: 0, 
                   y: isSelected ? 4 : AppShadows.small.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(AppColors.surface)
        )
    }
}

#Preview {
    SubscriptionPage()
} 