# Agron Onboarding Flow Guide

## Overview

The Agron app features a comprehensive onboarding experience designed to introduce users to the agricultural marketplace and guide them through account setup.

## Onboarding Flow Structure

### 1. Splash Screen
- **Purpose**: Brand introduction and app launch
- **Features**: 
  - Animated logo and branding
  - Gradient background with Agron colors
  - Smooth entrance animations
- **Duration**: 2-3 seconds with "Get Started" button

### 2. Onboarding Pages (5 pages)
- **Page 1**: Welcome to Agron - Introduction to the marketplace
- **Page 2**: Direct Trading - Benefits of direct farmer-buyer connections
- **Page 3**: Smart Delivery - Logistics and tracking features
- **Page 4**: Grow Your Business - Analytics and insights
- **Page 5**: Join the Community - Social proof and community benefits

**Features**:
- Swipeable page view with custom indicators
- Animated page transitions
- Skip and Next navigation options
- Responsive design with proper spacing

### 3. Role Selection
- **Purpose**: Determine user type for personalized experience
- **Roles Available**:
  - **Farmer**: Sell crops directly to buyers
  - **Buyer**: Purchase crops from farmers
  - **Transporter**: Provide delivery services

**Features**:
- Interactive role cards with icons and descriptions
- Selection state with visual feedback
- Role-specific feature highlights

### 4. Welcome Screen
- **Purpose**: Personalized welcome based on selected role
- **Features**:
  - Role-specific welcome message
  - Feature list tailored to user role
  - Smooth animations and transitions

### 5. Completion Screen
- **Purpose**: Final setup and transition to app
- **Features**:
  - Progress bar animation
  - Success confirmation
  - Smooth transition to main app

### 6. Subscription Page (Optional)
- **Purpose**: Premium feature introduction
- **Features**:
  - Feature grid layout
  - Subscription plan comparison
  - Skip option for free users

## Technical Implementation

### Key Files
- `OnboardingView.swift` - Main onboarding controller
- `WelcomeView.swift` - Role-specific welcome screen
- `OnboardingCompletionView.swift` - Final completion screen
- `SubscriptionPage.swift` - Premium features introduction
- `OnboardingResetView.swift` - Testing utility

### State Management
- Uses `@State` variables for flow control
- `UserDefaults` for persistence
- Smooth animations with `withAnimation`

### Design System Integration
- Consistent use of `AppColors`, `AppTypography`, `AppSpacing`
- Reusable components like `PrimaryButton`, `SecondaryButton`
- Responsive layout with proper spacing

## User Experience Features

### Animations
- Entrance animations for all screens
- Smooth page transitions
- Interactive feedback on user actions
- Progress indicators and loading states

### Navigation
- Intuitive swipe gestures
- Clear call-to-action buttons
- Skip options for power users
- Back navigation where appropriate

### Personalization
- Role-based content and messaging
- Tailored feature explanations
- Customized welcome experiences

## Testing

### Reset Functionality
- Available in Profile → Developer Options
- Resets all onboarding flags
- Allows testing of complete flow

### Development Features
- Preview support for all views
- Modular component design
- Easy customization and extension

## Flow Control

```swift
// Main flow states
@State private var showSplash = true
@State private var showRoleSelection = false
@State private var showWelcome = false
@State private var showCompletion = false
@State private var selectedRole: UserRole?
```

## Persistence

```swift
// UserDefaults keys
"hasSeenOnboarding" - Boolean
"hasSeenSubscription" - Boolean
"selectedRole" - String (role raw value)
```

## Customization

### Adding New Onboarding Pages
1. Add to `onboardingPages` array in `OnboardingView`
2. Update page indicators
3. Ensure proper navigation flow

### Modifying Role Selection
1. Update `UserRole` enum in `User.swift`
2. Add role-specific content in `WelcomeView`
3. Update role cards in `RoleSelectionView`

### Styling Changes
1. Modify `DesignSystem.swift` for global changes
2. Update individual view styling for specific changes
3. Ensure consistency across all onboarding screens

## Best Practices

1. **Performance**: Use lazy loading for images and heavy content
2. **Accessibility**: Include proper labels and voice-over support
3. **Internationalization**: Prepare for multiple languages
4. **Testing**: Test on different device sizes and orientations
5. **Analytics**: Track user progression through onboarding

## Future Enhancements

- A/B testing for different onboarding flows
- Video tutorials and demonstrations
- Interactive tutorials for key features
- Social proof and testimonials
- Gamification elements
- Offline support for onboarding content 