import SwiftUI

// MARK: - Color System
struct AppColors {
    static let primary = Color("AccentColor")
    static let primaryDark = Color("AccentColor").opacity(0.8) // or a custom dark color if you prefer
    static let secondary = Color.blue
    static let accent = Color(.systemOrange)
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    static let border = Color(.separator)
    static let error = Color.red
    static let success = Color.green
    static let info = Color(.systemTeal)
    static let warning = Color(.systemOrange)
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title1 = Font.title // Alias for compatibility
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // iPad-specific typography
    static func adaptiveBody(for sizeClass: UserInterfaceSizeClass?) -> Font {
        if sizeClass == .regular {
            return .system(size: 19, weight: .regular, design: .default)
        }
        return .body
    }
    
    static func adaptiveTitle(for sizeClass: UserInterfaceSizeClass?) -> Font {
        if sizeClass == .regular {
            return .system(size: 28, weight: .bold, design: .default)
        }
        return .title
    }
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    
    // iPad-specific spacing
    static func adaptiveHorizontal(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 40
        }
        return lg
    }
    
    static func adaptiveVertical(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 32
        }
        return xl
    }
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
}

// MARK: - Shadows
struct AppShadows {
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
}

// MARK: - Reusable Components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    
    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            print("🔘 PrimaryButton '\(title)' tapped")
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primary)
            .cornerRadius(AppCornerRadius.lg)
        }
        .disabled(isLoading)
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Ensure the entire button area is tappable
        .onTapGesture {
            print("🔘 PrimaryButton '\(title)' onTapGesture triggered")
            action()
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            print("🔘 SecondaryButton '\(title)' tapped")
            action()
        }) {
            Text(title)
                .font(AppTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(AppCornerRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Ensure the entire button area is tappable
        .onTapGesture {
            print("🔘 SecondaryButton '\(title)' onTapGesture triggered")
            action()
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    
    init(_ title: String, subtitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Text("See All")
                        .font(AppTypography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

struct StatusBadge: View {
    let status: String
    let color: Color
    
    init(_ status: String, color: Color = AppColors.primary) {
        self.status = status
        self.color = color
    }
    
    var body: some View {
        Text(status)
            .font(AppTypography.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(color.opacity(0.1))
            .cornerRadius(AppCornerRadius.sm)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(value)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .frame(width: 120, height: 80)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.lg)
        .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? AppColors.primary : AppColors.surface)
                .cornerRadius(AppCornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1)
                )
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)
            
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, action: action)
                    .padding(.horizontal, AppSpacing.xl)
            }
        }
        .padding(AppSpacing.xxl)
    }
}

// MARK: - Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding(AppSpacing.lg)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(AppTypography.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primary)
            .cornerRadius(AppCornerRadius.lg)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(AppTypography.headline)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primary.opacity(0.1))
            .cornerRadius(AppCornerRadius.lg)
    }
} 