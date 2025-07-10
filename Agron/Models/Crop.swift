import Foundation
import SwiftUI

struct Crop: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let quantity: Double
    let unit: String
    let price: Double
    let currency: String
    let location: String
    let availabilityDate: String
    let description: String?
    let farmerId: Int
    let farmerName: String
    let status: CropStatus
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, quantity, unit, price, currency, location, description
        case availabilityDate = "availability_date"
        case farmerId = "farmer_id"
        case farmerName = "farmer_name"
        case status, createdAt = "created_at"
    }
}

enum CropStatus: String, Codable, CaseIterable {
    case available = "available"
    case sold = "sold"
    case reserved = "reserved"
    
    var displayName: String {
        switch self {
        case .available: return "Available"
        case .sold: return "Sold"
        case .reserved: return "Reserved"
        }
    }
    
    var color: Color {
        switch self {
        case .available: return .green
        case .sold: return .red
        case .reserved: return .orange
        }
    }
} 