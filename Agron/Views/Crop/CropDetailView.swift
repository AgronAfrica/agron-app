import SwiftUI

struct CropDetailView: View {
    let crop: Crop
    @State private var showOrderSheet = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header image placeholder
                Rectangle()
                    .fill(Color.green.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    )
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and status
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(crop.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(crop.type)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(crop.status.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(crop.status.color).opacity(0.2))
                            .foregroundColor(Color(crop.status.color))
                            .cornerRadius(12)
                    }
                    
                    // Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(crop.currency) \(crop.price, specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        let quantityString = String(format: "%.1f", crop.quantity)
                        DetailRow(icon: "cube.box.fill", title: "Quantity", value: "\(quantityString) \(crop.unit)")
                        
                        DetailRow(icon: "location.fill", title: "Location", value: crop.location)
                        
                        DetailRow(icon: "calendar", title: "Available From", value: formatDate(crop.availabilityDate))
                        
                        DetailRow(icon: "person.fill", title: "Farmer", value: crop.farmerName)
                        
                        if let description = crop.description {
                            DetailRow(icon: "text.quote", title: "Description", value: description)
                        }
                    }
                    
                    // Order button
                    if crop.status == .available {
                        Button(action: {
                            showOrderSheet = true
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Place Order")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Crop Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOrderSheet) {
            PlaceOrderView(crop: crop)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        CropDetailView(crop: Crop(
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
} 