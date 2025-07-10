import Foundation

struct DeliveryJob: Codable, Identifiable {
    let id: Int
    let orderId: Int
    let orderNumber: String
    let pickupLocation: String
    let deliveryLocation: String
    let cropName: String
    let quantity: Double
    let unit: String
    let status: DeliveryStatus
    let farmerName: String
    let buyerName: String
    let transporterId: Int?
    let transporterName: String?
    let estimatedPickupDate: String?
    let estimatedDeliveryDate: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, orderId = "order_id", orderNumber = "order_number"
        case pickupLocation = "pickup_location", deliveryLocation = "delivery_location"
        case cropName = "crop_name", quantity, unit, status
        case farmerName = "farmer_name", buyerName = "buyer_name"
        case transporterId = "transporter_id", transporterName = "transporter_name"
        case estimatedPickupDate = "estimated_pickup_date"
        case estimatedDeliveryDate = "estimated_delivery_date"
        case createdAt = "created_at", updatedAt = "updated_at"
    }
}

enum DeliveryStatus: String, Codable, CaseIterable {
    case open = "open"
    case accepted = "accepted"
    case pickedUp = "picked_up"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .accepted: return "Accepted"
        case .pickedUp: return "Picked Up"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .open: return "blue"
        case .accepted: return "orange"
        case .pickedUp: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
} 