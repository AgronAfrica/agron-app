# AGRON Subscription Setup Guide

## 🎯 Overview

This guide covers the implementation of a paid subscription model using Apple's StoreKit 2 for the AGRON iOS app.

## 📋 Subscription Plans

### Weekly Plan
- **Price**: $3.99/week
- **Product ID**: `agron_weekly`
- **Free Trial**: 3 days
- **Billing Cycle**: Weekly

### Annual Plan
- **Price**: $39.99/year
- **Product ID**: `agron_yearly`
- **Free Trial**: None
- **Billing Cycle**: Annual
- **Savings**: 80% compared to weekly

## 🛠️ App Store Connect Setup

### 1. Create Subscription Group
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → **AGRON**
3. Go to **Features** → **In-App Purchases**
4. Click **+** to create a new subscription group
5. Name: `AGRON Access`
6. Reference Name: `AGRON_ACCESS`

### 2. Create Weekly Subscription
1. In the subscription group, click **+** to add subscription
2. **Product ID**: `agron_weekly`
3. **Reference Name**: `Weekly Plan`
4. **Subscription Duration**: 1 Week
5. **Price**: $3.99
6. **Free Trial**: 3 Days
7. **Localization**:
   - **Display Name**: Weekly Plan
   - **Description**: Weekly access to all AGRON features

### 3. Create Annual Subscription
1. In the same subscription group, click **+** to add another subscription
2. **Product ID**: `agron_yearly`
3. **Reference Name**: `Annual Plan`
4. **Subscription Duration**: 1 Year
5. **Price**: $39.99
6. **Free Trial**: None
7. **Localization**:
   - **Display Name**: Annual Plan
   - **Description**: Annual access to all AGRON features

## 🧑‍💻 iOS Implementation

### Files Created/Modified

1. **`SubscriptionManager.swift`** - Core subscription management
2. **`SubscriptionPage.swift`** - Subscription UI
3. **`SubscriptionStatusView.swift`** - Profile subscription status
4. **`OnboardingView.swift`** - Updated to show subscription
5. **`ContentView.swift`** - Updated to check subscription status
6. **`ProfileView.swift`** - Added subscription status section

### Key Features

#### SubscriptionManager
- ✅ StoreKit 2 integration
- ✅ Product loading and caching
- ✅ Purchase handling with verification
- ✅ Transaction listening
- ✅ Subscription status tracking
- ✅ Purchase restoration
- ✅ Error handling

#### SubscriptionPage
- ✅ Beautiful UI with feature highlights
- ✅ Weekly and annual plan options
- ✅ Free trial indication
- ✅ Restore purchases functionality
- ✅ Terms and privacy links
- ✅ Error alerts

#### SubscriptionStatusView
- ✅ Current subscription status
- ✅ Plan details and billing info
- ✅ Manage subscription link
- ✅ Subscribe now option for non-subscribers

## 🧪 Testing

### StoreKit Testing
1. Open Xcode project
2. Go to **Product** → **Scheme** → **Edit Scheme**
3. Select **Run** → **Options**
4. Set **StoreKit Configuration** to `StoreKitConfig.storekit`
5. Run the app in simulator or device

### Test Scenarios
- ✅ Load products successfully
- ✅ Purchase weekly subscription
- ✅ Purchase annual subscription
- ✅ Restore purchases
- ✅ Handle purchase errors
- ✅ Verify subscription status
- ✅ Test free trial period

### Sandbox Testing
1. Create sandbox test accounts in App Store Connect
2. Sign out of App Store on test device
3. Sign in with sandbox account
4. Test purchases with sandbox account

## 🔧 Configuration

### Info.plist Requirements
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Capabilities
- ✅ In-App Purchase capability enabled
- ✅ StoreKit framework imported

## 📱 User Flow

### New User Journey
1. **Onboarding** → Introduction screens
2. **Subscription Page** → Choose plan
3. **Purchase** → Complete payment
4. **Authentication** → Login/Register
5. **Dashboard** → Access app features

### Existing User Journey
1. **App Launch** → Check subscription status
2. **If Subscribed** → Go to dashboard
3. **If Not Subscribed** → Show subscription page

## 🔒 Security & Compliance

### StoreKit 2 Benefits
- ✅ Server-to-server verification
- ✅ Automatic receipt validation
- ✅ Enhanced security
- ✅ Better error handling
- ✅ Improved user experience

### Best Practices
- ✅ Always verify transactions server-side
- ✅ Handle network errors gracefully
- ✅ Provide clear error messages
- ✅ Implement restore purchases
- ✅ Test thoroughly before release

## 📊 Analytics & Tracking

### Events to Track
- Subscription page viewed
- Plan selected
- Purchase initiated
- Purchase completed
- Purchase failed
- Restore purchases
- Subscription status changes

### Backend Integration
```swift
// In SubscriptionManager.swift
private func notifyBackendAboutSubscription(_ transaction: Transaction) async {
    // TODO: Implement API call to update user subscription status
    // POST /api/users/subscription
    // {
    //   "user_id": "user_id",
    //   "product_id": transaction.productID,
    //   "purchase_date": transaction.originalPurchaseDate,
    //   "transaction_id": transaction.id
    // }
}
```

## 🚀 Deployment Checklist

### Pre-Release
- [ ] Test all subscription flows
- [ ] Verify product IDs match App Store Connect
- [ ] Test restore purchases functionality
- [ ] Verify error handling
- [ ] Test with sandbox accounts
- [ ] Review subscription terms and privacy policy

### App Store Submission
- [ ] Add subscription information to app description
- [ ] Include subscription terms in app metadata
- [ ] Test with TestFlight
- [ ] Verify App Store Connect configuration
- [ ] Submit for review

## 🆘 Troubleshooting

### Common Issues

#### Products Not Loading
- Check product IDs match App Store Connect
- Verify app bundle ID
- Check network connectivity
- Ensure StoreKit configuration is correct

#### Purchase Fails
- Verify sandbox account is active
- Check device is signed in to App Store
- Ensure sufficient funds in sandbox account
- Check for parental controls

#### Restore Not Working
- Verify user is signed in to App Store
- Check network connectivity
- Ensure app has proper entitlements

## 📞 Support

For issues with:
- **StoreKit Implementation**: Check Apple's [StoreKit 2 documentation](https://developer.apple.com/documentation/storekit)
- **App Store Connect**: Contact Apple Developer Support
- **Testing**: Use StoreKit testing framework
- **Backend Integration**: Implement server-side verification

## 📈 Revenue Optimization

### Tips for Higher Conversion
1. **Clear Value Proposition**: Highlight benefits clearly
2. **Free Trial**: 3-day trial for weekly plan
3. **Annual Discount**: 80% savings for annual plan
4. **Feature Comparison**: Show what's included
5. **Social Proof**: "Join thousands of users"
6. **Easy Cancellation**: Clear terms and conditions

### A/B Testing Ideas
- Different trial periods
- Price point variations
- Feature bundle combinations
- UI/UX variations
- Messaging variations

---

**Last Updated**: January 2025
**Version**: 1.0.0 