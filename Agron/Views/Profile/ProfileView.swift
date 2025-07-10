import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingLogoutAlert = false
    @State private var showingSubscriptionStatus = false
    @State private var showingResetOnboarding = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: AppSpacing.lg) {
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        VStack(spacing: AppSpacing.sm) {
                            Text(authManager.currentUser?.name ?? "User")
                                .font(AppTypography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                            
                            if let role = authManager.currentUser?.role {
                                StatusBadge(role.rawValue.capitalized, color: AppColors.primary)
                            }
                        }
                    }
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.lg)
                    
                    // Quick Actions
                    VStack(spacing: AppSpacing.md) {
                        SectionHeader("Quick Actions")
                        
                        VStack(spacing: AppSpacing.sm) {
                            ProfileActionRow(
                                icon: "crown.fill",
                                title: "Subscription Status",
                                subtitle: "Manage your subscription",
                                color: AppColors.secondary
                            ) {
                                showingSubscriptionStatus = true
                            }
                            
                            ProfileActionRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Manage notification preferences",
                                color: AppColors.info
                            ) {
                                // Handle notifications
                            }
                            
                            ProfileActionRow(
                                icon: "shield.fill",
                                title: "Privacy & Security",
                                subtitle: "Manage your account security",
                                color: AppColors.warning
                            ) {
                                // Handle privacy
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Account Settings
                    VStack(spacing: AppSpacing.md) {
                        SectionHeader("Account Settings")
                        
                        VStack(spacing: AppSpacing.sm) {
                            ProfileActionRow(
                                icon: "person.fill",
                                title: "Edit Profile",
                                subtitle: "Update your personal information",
                                color: AppColors.primary
                            ) {
                                // Handle edit profile
                            }
                            
                            ProfileActionRow(
                                icon: "location.fill",
                                title: "Location Settings",
                                subtitle: "Manage your location preferences",
                                color: AppColors.accent
                            ) {
                                // Handle location settings
                            }
                            
                            ProfileActionRow(
                                icon: "creditcard.fill",
                                title: "Payment Methods",
                                subtitle: "Manage your payment options",
                                color: AppColors.success
                            ) {
                                // Handle payment methods
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Support & Help
                    VStack(spacing: AppSpacing.md) {
                        SectionHeader("Support & Help")
                        
                        VStack(spacing: AppSpacing.sm) {
                            ProfileActionRow(
                                icon: "questionmark.circle.fill",
                                title: "Help Center",
                                subtitle: "Get help and find answers",
                                color: AppColors.info
                            ) {
                                // Handle help center
                            }
                            
                            ProfileActionRow(
                                icon: "envelope.fill",
                                title: "Contact Support",
                                subtitle: "Get in touch with our team",
                                color: AppColors.primary
                            ) {
                                // Handle contact support
                            }
                            
                            ProfileActionRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                subtitle: "Read our terms and conditions",
                                color: AppColors.textSecondary
                            ) {
                                // Handle terms
                            }
                            
                            ProfileActionRow(
                                icon: "hand.raised.fill",
                                title: "Privacy Policy",
                                subtitle: "Learn about our privacy practices",
                                color: AppColors.textSecondary
                            ) {
                                // Handle privacy policy
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Developer Options (for testing)
                    VStack(spacing: AppSpacing.md) {
                        SectionHeader("Developer Options")
                        
                        VStack(spacing: AppSpacing.sm) {
                            ProfileActionRow(
                                icon: "arrow.clockwise.circle.fill",
                                title: "Reset Onboarding",
                                subtitle: "Reset onboarding flow for testing",
                                color: AppColors.error
                            ) {
                                showingResetOnboarding = true
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Logout Section
                    VStack(spacing: AppSpacing.md) {
                        PrimaryButton("Logout") {
                            showingLogoutAlert = true
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        Text("Version 1.0.0")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .sheet(isPresented: $showingSubscriptionStatus) {
            SubscriptionStatusView()
        }
        .sheet(isPresented: $showingResetOnboarding) {
            OnboardingResetView()
        }
    }
}

// MARK: - Supporting Views
struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(AppCornerRadius.md)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(AppSpacing.lg)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
} 