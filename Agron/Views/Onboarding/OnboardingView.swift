import SwiftUI

enum OnboardingState {
    case splash
    case onboarding
    case roleSelection
    case roleSpecificOnboarding
    case welcome
    case completion
}

struct OnboardingView: View {
    @State private var currentState: OnboardingState = .splash
    @State private var currentPage = 0
    @State private var hasSeenOnboarding = false
    @State private var selectedRole: UserRole?
    let onComplete: () -> Void
    
    private let onboardingPages = [
        OnboardingPage(
            image: "leaf.fill",
            title: "Welcome to Agron",
            subtitle: "Your Agricultural Marketplace",
            description: "Connect directly with farmers, buyers, and transporters across Nigeria. Eliminate middlemen and get better prices for everyone."
        ),
        OnboardingPage(
            image: "handshake",
            title: "Direct Trading",
            subtitle: "Connect directly with farmers and buyers",
            description: "Trade directly with verified farmers and buyers. No middlemen, better prices, and transparent transactions."
        ),
        OnboardingPage(
            image: "truck.box.fill",
            title: "Smart Delivery",
            subtitle: "Efficient logistics and tracking",
            description: "Track your deliveries in real-time. Our network of transporters ensures your crops reach their destination safely and on time."
        ),
        OnboardingPage(
            image: "chart.line.uptrend.xyaxis",
            title: "Grow Your Business",
            subtitle: "Analytics and insights to help you succeed",
            description: "Get detailed analytics, market insights, and performance metrics to make informed decisions and grow your agricultural business."
        ),
        OnboardingPage(
            image: "person.3.fill",
            title: "Join the Community",
            subtitle: "Be part of Nigeria's agricultural revolution",
            description: "Join thousands of farmers, buyers, and transporters who are already using Agron to grow their businesses."
        )
    ]
    
    var body: some View {
        Group {
            switch currentState {
            case .splash:
                SplashScreen {
                    print("🎯 SplashScreen Get Started tapped")
                    withAnimation(.easeInOut(duration: 0.8)) {
                        currentState = .onboarding
                    }
                }
                
            case .onboarding:
                // Main onboarding pages
                ZStack {
                    AppColors.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Content
                        TabView(selection: $currentPage) {
                            ForEach(0..<onboardingPages.count, id: \.self) { index in
                                OnboardingPageView(
                                    page: onboardingPages[index],
                                    isLastPage: index == onboardingPages.count - 1,
                                    onNext: {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentPage = min(currentPage + 1, onboardingPages.count - 1)
                                        }
                                    },
                                    onSkip: {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentState = .roleSelection
                                        }
                                    },
                                    onGetStarted: {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentState = .roleSelection
                                        }
                                    }
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                        
                        // Page Indicators
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(0..<onboardingPages.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? AppColors.primary : AppColors.border)
                                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        .padding(.bottom, AppSpacing.lg)
                        
                        // Bottom Section
                        VStack(spacing: AppSpacing.md) {
                            // Action Buttons
                            VStack(spacing: AppSpacing.md) {
                                if currentPage == onboardingPages.count - 1 {
                                    PrimaryButton("Get Started") {
                                        print("🎯 Onboarding Get Started button tapped")
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentState = .roleSelection
                                        }
                                    }
                                } else {
                                    HStack(spacing: AppSpacing.md) {
                                        SecondaryButton(title: "Skip") {
                                            print("🎯 Onboarding Skip button tapped")
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                currentState = .roleSelection
                                            }
                                        }
                                        
                                        PrimaryButton("Next") {
                                            print("🎯 Onboarding Next button tapped")
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                currentPage = min(currentPage + 1, onboardingPages.count - 1)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
                .onAppear {
                    print("🎯 Showing main onboarding pages, currentPage: \(currentPage)")
                }
                
            case .roleSelection:
                RoleSelectionView(selectedRole: $selectedRole) {
                    print("🎯 RoleSelectionView onComplete called, transitioning to role-specific onboarding")
                    if selectedRole != nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentState = .roleSpecificOnboarding
                        }
                    }
                }
                .onAppear {
                    print("🎯 Showing RoleSelectionView")
                }
                
            case .roleSpecificOnboarding:
                if let role = selectedRole {
                    RoleSpecificOnboardingView(selectedRole: role) {
                        print("🎯 RoleSpecificOnboardingView continue button tapped")
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentState = .welcome
                        }
                    }
                    .onAppear {
                        print("🎯 Showing RoleSpecificOnboardingView for role: \(role)")
                    }
                }
                
            case .welcome:
                if let role = selectedRole {
                    WelcomeView(selectedRole: role) {
                        print("🎯 WelcomeView continue button tapped")
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentState = .completion
                        }
                    }
                    .onAppear {
                        print("🎯 Showing WelcomeView for role: \(role)")
                    }
                }
                
            case .completion:
                if let role = selectedRole {
                    OnboardingCompletionView(selectedRole: role) {
                        print("🎯 OnboardingCompletionView continue button tapped")
                        hasSeenOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        UserDefaults.standard.set(role.rawValue, forKey: "selectedRole")
                        onComplete() // Call the completion callback
                    }
                    .onAppear {
                        print("🎯 Showing OnboardingCompletionView for role: \(role)")
                    }
                }
            }
        }
        .onChange(of: hasSeenOnboarding) { _, newValue in
            if newValue {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            }
        }
    }
}

struct SplashScreen: View {
    var onGetStarted: () -> Void
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 32) {
                    // Logo with animation
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    VStack(spacing: 8) {
                        Text("Agron")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Agricultural Marketplace")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .opacity(textOpacity)
                }
                
                Spacer()
                
                // Get Started Button
                Button(action: onGetStarted) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .opacity(buttonOpacity)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                buttonOpacity = 1.0
            }
        }
    }
}

struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole?
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    // Header
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary)
                        VStack(spacing: AppSpacing.md) {
                            Text("Choose Your Role")
                                .font(AppTypography.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.textPrimary)
                            Text("Select the role that best describes your business")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.top, AppSpacing.xxl)
                    // Role Cards
                    VStack(spacing: AppSpacing.lg) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            RoleCard(
                                role: role,
                                isSelected: selectedRole == role,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedRole = role
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    // Continue Button
                    if selectedRole != nil {
                        PrimaryButton("Continue") {
                            print("🎯 RoleSelectionView Continue button tapped, selectedRole: \(selectedRole?.rawValue ?? "nil")")
                            onComplete()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.xl)
                    }
                    Spacer(minLength: AppSpacing.xxl)
                }
            }
        }
    }
}

struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary : AppColors.primary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: roleIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.primary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(role.displayName)
                        .font(AppTypography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(roleDescription)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary)
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
    
    private var roleIcon: String {
        switch role {
        case .farmer: return "leaf.fill"
        case .buyer: return "cart.fill"
        case .transporter: return "truck.box.fill"
        }
    }
    
    private var roleDescription: String {
        switch role {
        case .farmer: return "Sell your crops directly to buyers, eliminate middlemen, and maximize your profits with better prices and direct market access."
        case .buyer: return "Purchase quality crops directly from verified farmers, get competitive prices, and ensure reliable delivery to your business."
        case .transporter: return "Provide delivery services, earn from transportation jobs, and build your reputation while helping farmers and buyers connect."
        }
    }
}

// MARK: - Supporting Views
struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
    let description: String
    
    init(image: String, title: String, subtitle: String, description: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onNext: (() -> Void)?
    let onSkip: (() -> Void)?
    let onGetStarted: (() -> Void)?
    @State private var imageScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            // Icon with animation
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 140, height: 140)
                Image(systemName: page.image)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }
            .scaleEffect(imageScale)
            .padding(.top, AppSpacing.xxl)
            // Content
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.md) {
                    Text(page.title)
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textPrimary)
                    Text(page.subtitle)
                        .font(AppTypography.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.primary)
                }
                Text(page.description)
                    .font(AppTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.xl)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            Spacer()
            // REMOVE: Action Buttons from here
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                imageScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

// MARK: - Role-Specific Onboarding View
struct RoleSpecificOnboardingView: View {
    let selectedRole: UserRole
    let onContinue: () -> Void
    
    @State private var currentPage = 0
    @State private var showContent = false
    
    private var roleSpecificPages: [OnboardingPage] {
        switch selectedRole {
        case .farmer:
            return [
                OnboardingPage(
                    image: "leaf.fill",
                    title: "Sell Your Crops",
                    subtitle: "Direct to buyers, better prices",
                    description: "List your crops and set your own prices. Connect directly with buyers and eliminate middlemen for maximum profit."
                ),
                OnboardingPage(
                    image: "chart.bar.fill",
                    title: "Track Your Business",
                    subtitle: "Analytics and insights",
                    description: "Monitor your sales, track market trends, and get insights to optimize your farming business."
                ),
                OnboardingPage(
                    image: "truck.box.fill",
                    title: "Easy Delivery",
                    subtitle: "We handle the logistics",
                    description: "Our network of transporters will pick up and deliver your crops safely to buyers across Nigeria."
                )
            ]
        case .buyer:
            return [
                OnboardingPage(
                    image: "cart.fill",
                    title: "Quality Crops",
                    subtitle: "Direct from farmers",
                    description: "Browse and purchase quality crops directly from verified farmers. No middlemen, better prices."
                ),
                OnboardingPage(
                    image: "magnifyingglass",
                    title: "Compare & Choose",
                    subtitle: "Find the best deals",
                    description: "Compare prices, quality, and delivery options from multiple farmers to get the best value."
                ),
                OnboardingPage(
                    image: "clock.fill",
                    title: "Fast Delivery",
                    subtitle: "Track your orders",
                    description: "Track your orders in real-time and get notified when your crops are on the way."
                )
            ]
        case .transporter:
            return [
                OnboardingPage(
                    image: "truck.box.fill",
                    title: "Accept Jobs",
                    subtitle: "Earn from deliveries",
                    description: "Browse and accept delivery jobs from farmers and buyers. Set your rates and earn from transportation."
                ),
                OnboardingPage(
                    image: "location.fill",
                    title: "Track Deliveries",
                    subtitle: "Real-time updates",
                    description: "Track your deliveries in real-time and keep customers updated on delivery progress."
                ),
                OnboardingPage(
                    image: "star.fill",
                    title: "Build Reputation",
                    subtitle: "Grow your business",
                    description: "Earn ratings and reviews from customers. Build your reputation to get more delivery jobs."
                )
            ]
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: AppSpacing.md) {
                    Text("Welcome, \(selectedRole.displayName)!")
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, AppSpacing.xl)
                    
                    Text("Here's how Agron works for you")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                .opacity(showContent ? 1.0 : 0)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<roleSpecificPages.count, id: \.self) { index in
                        RoleSpecificPageView(
                            page: roleSpecificPages[index],
                            isLastPage: index == roleSpecificPages.count - 1
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Page Indicators
                HStack(spacing: AppSpacing.sm) {
                    ForEach(0..<roleSpecificPages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.primary : AppColors.border)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, AppSpacing.lg)
                .opacity(showContent ? 1.0 : 0)
                
                // Action Buttons
                VStack(spacing: AppSpacing.md) {
                    if currentPage == roleSpecificPages.count - 1 {
                        PrimaryButton("Continue") {
                            print("🎯 RoleSpecificOnboardingView Continue button tapped")
                            onContinue()
                        }
                    } else {
                        HStack(spacing: AppSpacing.md) {
                            SecondaryButton(title: "Skip") {
                                print("🎯 RoleSpecificOnboardingView Skip button tapped")
                                onContinue()
                            }
                            
                            PrimaryButton("Next") {
                                print("🎯 RoleSpecificOnboardingView Next button tapped")
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage = min(currentPage + 1, roleSpecificPages.count - 1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
                .opacity(showContent ? 1.0 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

struct RoleSpecificPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @State private var imageScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            // Icon with animation
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 140, height: 140)
                Image(systemName: page.image)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }
            .scaleEffect(imageScale)
            .padding(.top, AppSpacing.xxl)
            
            // Content
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.md) {
                    Text(page.title)
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textPrimary)
                    Text(page.subtitle)
                        .font(AppTypography.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.primary)
                }
                Text(page.description)
                    .font(AppTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.xl)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                imageScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    OnboardingView {
        // Preview completion handler
    }
} 