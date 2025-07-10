import SwiftUI

struct PlaceOrderView: View {
    let crop: Crop
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = ""
    @State private var pickupLocation = ""
    @State private var deliveryLocation = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var totalPrice: Double {
        let quantityValue = Double(quantity) ?? 0
        return quantityValue * crop.price
    }
    
    private var isFormValid: Bool {
        !quantity.isEmpty && !pickupLocation.isEmpty && 
        Double(quantity) ?? 0 > 0 && Double(quantity) ?? 0 <= crop.quantity
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Crop summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Summary")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(crop.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text(crop.type)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(crop.currency) \(crop.price, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Order form
                    VStack(spacing: 16) {
                        // Quantity
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quantity")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                TextField("0.0", text: $quantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                
                                Text(crop.unit)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Available: \(crop.quantity, specifier: "%.1f") \(crop.unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Pickup location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pickup Location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter pickup location", text: $pickupLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Delivery location (optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Delivery Location (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter delivery location", text: $deliveryLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // Total price
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Total")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("Total Price:")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(crop.currency) \(totalPrice, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding(16)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Place order button
                    Button(action: {
                        placeOrder()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "cart.badge.plus")
                                Text("Place Order")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isLoading || !isFormValid ? 0.6 : 1.0)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Place Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
    
    private func placeOrder() {
        isLoading = true
        
        let orderRequest = OrderCreateRequest(
            cropId: crop.id,
            quantity: Double(quantity) ?? 0,
            pickupLocation: pickupLocation,
            deliveryLocation: deliveryLocation.isEmpty ? nil : deliveryLocation
        )
        
        Task {
            do {
                let _ = try await APIService.shared.createOrder(order: orderRequest)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    PlaceOrderView(crop: Crop(
        id: 1,
        name: "Fresh Cassava",
        type: "Cassava",
        quantity: 100.0,
        unit: "kg",
        price: 5000.0,
        currency: "₦",
        location: "Lagos, Nigeria",
        availabilityDate: "2025-01-15",
        description: "Fresh cassava from local farm",
        farmerId: 1,
        farmerName: "John Doe",
        status: .available,
        createdAt: "2025-01-10"
    ))
} 