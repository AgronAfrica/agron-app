import SwiftUI

struct WelcomeView: View {
    let selectedRole: UserRole
    let onContinue: () -> Void
    
    @State private var showContent = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    // Welcome Content
                    VStack(spacing: AppSpacing.xl) {
                        // Role Icon
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: roleIcon)
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Welcome Text
                        VStack(spacing: AppSpacing.lg) {
                            Text("Welcome, \(selectedRole.displayName)!")
                                .font(AppTypography.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(welcomeMessage)
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.lg)
                                .lineSpacing(4)
                        }
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Key Benefits
                        VStack(spacing: AppSpacing.md) {
                            Text("Key Benefits:")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(keyBenefits, id: \.self) { benefit in
                                    HStack(spacing: AppSpacing.md) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.success)
                                        
                                        Text(benefit)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Features for this role
                        VStack(spacing: AppSpacing.md) {
                            Text("What you can do:")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(roleFeatures, id: \.self) { feature in
                                    HStack(spacing: AppSpacing.md) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.primary)
                                        
                                        Text(feature)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Getting Started Tips
                        VStack(spacing: AppSpacing.md) {
                            Text("Getting Started:")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(gettingStartedTips, id: \.self) { tip in
                                    HStack(spacing: AppSpacing.md) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.warning)
                                        
                                        Text(tip)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .opacity(showContent ? 1.0 : 0)
                    }
                    
                    // Continue Button
                    PrimaryButton("Get Started") {
                        print("🎯 WelcomeView Get Started button tapped")
                        onContinue()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .opacity(showButton ? 1.0 : 0)
                    .padding(.bottom, AppSpacing.xl)
                }
                .padding(.top, AppSpacing.xl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                showButton = true
            }
        }
    }
    
    private var roleIcon: String {
        switch selectedRole {
        case .farmer: return "leaf.fill"
        case .buyer: return "cart.fill"
        case .transporter: return "truck.box.fill"
        }
    }
    
    private var welcomeMessage: String {
        switch selectedRole {
        case .farmer:
            return "Ready to sell your crops directly to buyers and grow your farm business? Let's get you set up to maximize your profits!"
        case .buyer:
            return "Ready to purchase quality crops directly from farmers? Let's connect you with the best suppliers and get you the best deals!"
        case .transporter:
            return "Ready to provide delivery services and earn from transportation jobs? Let's get you started on building your delivery business!"
        }
    }
    
    private var keyBenefits: [String] {
        switch selectedRole {
        case .farmer:
            return [
                "Eliminate middlemen and get better prices",
                "Direct access to verified buyers",
                "Real-time market insights and analytics",
                "Secure payment processing",
                "Professional delivery network"
            ]
        case .buyer:
            return [
                "Direct access to quality crops from farmers",
                "Competitive pricing with no middlemen",
                "Quality verification and guarantees",
                "Fast and reliable delivery",
                "Transparent pricing and terms"
            ]
        case .transporter:
            return [
                "Flexible job opportunities",
                "Competitive rates and earnings",
                "Real-time tracking and updates",
                "Build reputation and ratings",
                "Secure payment processing"
            ]
        }
    }
    
    private var roleFeatures: [String] {
        switch selectedRole {
        case .farmer:
            return [
                "List and sell your crops directly to buyers",
                "Set your own prices and terms",
                "Track orders and manage deliveries",
                "Access market insights and analytics",
                "Manage your farm operations",
                "Build your reputation and ratings"
            ]
        case .buyer:
            return [
                "Browse and purchase crops from verified farmers",
                "Compare prices and quality",
                "Track orders and deliveries",
                "Manage your inventory efficiently",
                "Access market trends and insights",
                "Build relationships with reliable suppliers"
            ]
        case .transporter:
            return [
                "Accept delivery jobs from farmers and buyers",
                "Track deliveries in real-time",
                "Earn from transportation services",
                "Build your reputation and ratings",
                "Set your own rates and schedules",
                "Access job analytics and insights"
            ]
        }
    }
    
    private var gettingStartedTips: [String] {
        switch selectedRole {
        case .farmer:
            return [
                "Complete your profile with farm details",
                "Upload photos of your crops",
                "Set competitive prices based on market rates",
                "Respond quickly to buyer inquiries",
                "Maintain quality standards for better ratings"
            ]
        case .buyer:
            return [
                "Complete your profile and preferences",
                "Browse available crops and farmers",
                "Compare prices and delivery options",
                "Read reviews and ratings before purchasing",
                "Track your orders and deliveries"
            ]
        case .transporter:
            return [
                "Complete your profile with vehicle details",
                "Set your delivery rates and coverage areas",
                "Browse available delivery jobs",
                "Accept jobs that match your schedule",
                "Provide excellent service to build ratings"
            ]
        }
    }
}

#Preview {
    WelcomeView(selectedRole: .farmer) {
        // Handle continue action
    }
} 