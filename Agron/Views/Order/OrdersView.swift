import SwiftUI

struct OrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Orders")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Track your orders and deliveries")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if orders.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "list.bullet")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No orders yet")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Your orders will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(orders) { order in
                                OrderCard(order: order)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadOrders()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func loadOrders() {
        isLoading = true
        
        Task {
            do {
                let fetchedOrders = try await APIService.shared.getUserOrders()
                await MainActor.run {
                    self.orders = fetchedOrders
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct OrderCard: View {
    let order: Order
    @State private var showOrderDetail = false
    
    var body: some View {
        Button(action: {
            showOrderDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.cropName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Order #\(order.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(order.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(order.status.color).opacity(0.2))
                        .foregroundColor(Color(order.status.color))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "cube.box.fill")
                            .foregroundColor(.orange)
                        Text("\(order.quantity, specifier: "%.1f") \(order.unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                        Text("Pickup: \(order.pickupLocation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let deliveryLocation = order.deliveryLocation {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text("Delivery: \(deliveryLocation)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        Text("Farmer: \(order.farmerName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(order.currency) \(order.totalPrice, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Text("View Details")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showOrderDetail) {
            OrderDetailView(order: order)
        }
    }
}

#Preview {
    OrdersView()
} 