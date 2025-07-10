import SwiftUI

struct CropCard: View {
    let crop: Crop
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(crop.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(crop.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(crop.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(crop.status.color.opacity(0.2))
                    .foregroundColor(crop.status.color)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    Text(crop.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "cube.box.fill")
                        .foregroundColor(.orange)
                    Text("\(crop.quantity, specifier: "%.1f") \(crop.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Available: \(formatDate(crop.availabilityDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.purple)
                    Text("By \(crop.farmerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(crop.currency) \(crop.price, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("View Details")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(16)
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    CropCard(crop: Crop(
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
    )) {
        // Action
    }
    .padding()
} 