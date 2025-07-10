import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order status
                    VStack(spacing: 16) {
                        Text("Order Status")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(order.status.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(order.status.color))
                            
                            Spacer()
                            
                            Image(systemName: statusIcon)
                                .font(.title)
                                .foregroundColor(Color(order.status.color))
                        }
                        .padding(16)
                        .background(Color(order.status.color).opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Order details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            DetailRow(icon: "tag.fill", title: "Order ID", value: "#\(order.id)")
                            
                            DetailRow(icon: "leaf.fill", title: "Crop", value: order.cropName)
                            
                            DetailRow(icon: "cube.box.fill", title: "Quantity", value: String(format: "%.1f %@", order.quantity, order.unit))
                            
                            DetailRow(icon: "dollarsign.circle.fill", title: "Total Price", value: String(format: "%@ %.2f", order.currency, order.totalPrice))
                            
                            DetailRow(icon: "calendar", title: "Order Date", value: formatDate(order.createdAt))
                        }
                    }
                    
                    // Location details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Location Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            DetailRow(icon: "location.fill", title: "Pickup Location", value: order.pickupLocation)
                            
                            if let deliveryLocation = order.deliveryLocation {
                                DetailRow(icon: "location", title: "Delivery Location", value: deliveryLocation)
                            }
                        }
                    }
                    
                    // People involved
                    VStack(alignment: .leading, spacing: 16) {
                        Text("People Involved")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            DetailRow(icon: "person.fill", title: "Farmer", value: order.farmerName)
                            
                            DetailRow(icon: "person.fill", title: "Buyer", value: order.buyerName)
                            
                            if let transporterName = order.transporterName {
                                DetailRow(icon: "truck.box.fill", title: "Transporter", value: transporterName)
                            }
                        }
                    }
                    
                    // Tracking timeline
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Timeline")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            TimelineItem(
                                status: .pending,
                                title: "Order Placed",
                                description: "Your order has been placed",
                                isCompleted: order.status != .pending,
                                isCurrent: order.status == .pending
                            )
                            
                            TimelineItem(
                                status: .confirmed,
                                title: "Order Confirmed",
                                description: "Farmer has confirmed your order",
                                isCompleted: [.confirmed, .inTransit, .delivered].contains(order.status),
                                isCurrent: order.status == .confirmed
                            )
                            
                            TimelineItem(
                                status: .inTransit,
                                title: "In Transit",
                                description: "Your order is being delivered",
                                isCompleted: order.status == .delivered,
                                isCurrent: order.status == .inTransit
                            )
                            
                            TimelineItem(
                                status: .delivered,
                                title: "Delivered",
                                description: "Your order has been delivered",
                                isCompleted: order.status == .delivered,
                                isCurrent: order.status == .delivered
                            )
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private var statusIcon: String {
        switch order.status {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .inTransit: return "truck.box.fill"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

struct TimelineItem: View {
    let status: OrderStatus
    let title: String
    let description: String
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Timeline dot
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isCurrent ? Color.orange : Color.gray.opacity(0.3)))
                    .frame(width: 12, height: 12)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted || isCurrent ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OrderDetailView(order: Order(
        id: 1,
        cropId: 1,
        cropName: "Fresh Cassava",
        buyerId: 2,
        buyerName: "Jane Smith",
        farmerId: 1,
        farmerName: "John Doe",
        quantity: 50.0,
        unit: "kg",
        totalPrice: 2500.0,
        currency: "₦",
        status: .confirmed,
        pickupLocation: "Lagos, Nigeria",
        deliveryLocation: "Abuja, Nigeria",
        transporterId: 3,
        transporterName: "Mike Johnson",
        createdAt: "2025-01-10T10:30:00.000000Z",
        updatedAt: "2025-01-10T11:00:00.000000Z"
    ))
} 