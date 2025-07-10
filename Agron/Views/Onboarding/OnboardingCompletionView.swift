import SwiftUI

struct OnboardingCompletionView: View {
    let selectedRole: UserRole
    let onComplete: () -> Void
    
    @State private var showContent = false
    @State private var showButton = false
    @State private var progressValue: CGFloat = 0
    @State private var showNextSteps = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    // Completion Content
                    VStack(spacing: AppSpacing.xl) {
                        // Success Icon
                        ZStack {
                            Circle()
                                .fill(AppColors.success.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60, weight: .semibold))
                                .foregroundColor(AppColors.success)
                        }
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Completion Text
                        VStack(spacing: AppSpacing.lg) {
                            Text("You're All Set!")
                                .font(AppTypography.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Welcome to Agron, \(selectedRole.displayName). Your account is ready to help you grow your agricultural business.")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.lg)
                                .lineSpacing(4)
                        }
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Progress Bar
                        VStack(spacing: AppSpacing.md) {
                            Text("Setting up your experience...")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            ProgressView(value: progressValue)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                                .frame(height: 8)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                        .opacity(showContent ? 1.0 : 0)
                        
                        // Next Steps
                        VStack(spacing: AppSpacing.md) {
                            Text("Next Steps:")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(nextSteps, id: \.self) { step in
                                    HStack(spacing: AppSpacing.md) {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(AppColors.primary)
                                        
                                        Text(step)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .opacity(showNextSteps ? 1.0 : 0)
                        
                        // Quick Tips
                        VStack(spacing: AppSpacing.md) {
                            Text("Quick Tips:")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(quickTips, id: \.self) { tip in
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
                        .opacity(showNextSteps ? 1.0 : 0)
                    }
                    
                    // Continue Button
                    PrimaryButton("Enter Agron") {
                        print("🎯 OnboardingCompletionView Enter Agron button tapped")
                        onComplete()
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
            
            // Animate progress bar
            withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
                progressValue = 1.0
            }
            
            // Show next steps after progress
            withAnimation(.easeOut(duration: 0.8).delay(2.5)) {
                showNextSteps = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(3.0)) {
                showButton = true
            }
        }
    }
    
    private var nextSteps: [String] {
        switch selectedRole {
        case .farmer:
            return [
                "Complete your farm profile",
                "Add your first crop listing",
                "Set up payment methods",
                "Connect with buyers"
            ]
        case .buyer:
            return [
                "Complete your buyer profile",
                "Browse available crops",
                "Set up payment methods",
                "Start your first purchase"
            ]
        case .transporter:
            return [
                "Complete your transporter profile",
                "Add your vehicle details",
                "Set your delivery rates",
                "Browse available jobs"
            ]
        }
    }
    
    private var quickTips: [String] {
        switch selectedRole {
        case .farmer:
            return [
                "Upload high-quality photos of your crops",
                "Set competitive prices based on market rates",
                "Respond quickly to buyer inquiries",
                "Maintain quality standards for better ratings"
            ]
        case .buyer:
            return [
                "Read reviews before making purchases",
                "Compare prices from multiple farmers",
                "Track your orders and deliveries",
                "Build relationships with reliable suppliers"
            ]
        case .transporter:
            return [
                "Accept jobs that match your schedule",
                "Provide excellent service to build ratings",
                "Keep customers updated on delivery progress",
                "Maintain your vehicle for reliable service"
            ]
        }
    }
}

#Preview {
    OnboardingCompletionView(selectedRole: .farmer) {
        // Handle completion action
    }
} 