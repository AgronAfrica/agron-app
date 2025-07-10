import SwiftUI

struct OnboardingResetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                VStack(spacing: AppSpacing.lg) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Reset Onboarding")
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("This will reset the onboarding flow and allow you to see it again. This is useful for testing purposes.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                
                Spacer()
                
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton("Reset Onboarding") {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                        UserDefaults.standard.set(false, forKey: "hasSeenSubscription")
                        UserDefaults.standard.removeObject(forKey: "selectedRole")
                        dismiss()
                    }
                    
                    SecondaryButton(title: "Cancel") {
                        dismiss()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .navigationTitle("Reset")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    OnboardingResetView()
} 