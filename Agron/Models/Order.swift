import Foundation

struct Order: Codable, Identifiable {
    let id: Int
    let cropId: Int
    let cropName: String
    let buyerId: Int
    let buyerName: String
    let farmerId: Int
    let farmerName: String
    let quantity: Double
    let unit: String
    let totalPrice: Double
    let currency: String
    let status: OrderStatus
    let pickupLocation: String
    let deliveryLocation: String?
    let transporterId: Int?
    let transporterName: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, cropId = "crop_id", cropName = "crop_name"
        case buyerId = "buyer_id", buyerName = "buyer_name"
        case farmerId = "farmer_id", farmerName = "farmer_name"
        case quantity, unit, totalPrice = "total_price", currency, status
        case pickupLocation = "pickup_location"
        case deliveryLocation = "delivery_location"
        case transporterId = "transporter_id", transporterName = "transporter_name"
        case createdAt = "created_at", updatedAt = "updated_at"
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inTransit = "in_transit"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .inTransit: return "In Transit"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .inTransit: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
} 