import SwiftUI
import StoreKit

struct SubscriptionStatusView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionPage = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Subscription")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if subscriptionManager.isSubscribed {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text("Inactive")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if subscriptionManager.isSubscribed {
                // Active subscription details
                VStack(spacing: 16) {
                    let subscriptionInfo = subscriptionManager.getCurrentSubscriptionInfo()
                    
                    if let productID = subscriptionInfo.productID {
                        SubscriptionDetailRow(
                            title: "Current Plan",
                            value: getPlanName(for: productID)
                        )
                        
                        if let startDate = subscriptionInfo.startDate {
                            SubscriptionDetailRow(
                                title: "Started",
                                value: formatDate(startDate)
                            )
                        }
                        
                        SubscriptionDetailRow(
                            title: "Next Billing",
                            value: getNextBillingDate(for: productID)
                        )
                    }
                    
                    Button(action: {
                        // Open App Store subscription management
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Manage Subscription")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                // No active subscription
                VStack(spacing: 16) {
                    Text("No active subscription")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showSubscriptionPage = true
                    }) {
                        Text("Subscribe Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .sheet(isPresented: $showSubscriptionPage) {
            SubscriptionPage()
        }
    }
    
    private func getPlanName(for productID: String) -> String {
        switch productID {
        case "agron_weekly":
            return "Weekly Plan ($3.99/week)"
        case "agron_yearly":
            return "Annual Plan ($39.99/year)"
        default:
            return "Unknown Plan"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getNextBillingDate(for productID: String) -> String {
        // This would typically be calculated based on the subscription period
        // For now, returning a placeholder
        switch productID {
        case "agron_weekly":
            return "Next week"
        case "agron_yearly":
            return "Next year"
        default:
            return "Unknown"
        }
    }
}

struct SubscriptionDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SubscriptionStatusView()
        .padding()
} 