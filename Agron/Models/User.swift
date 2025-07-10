import Foundation

enum UserRole: String, CaseIterable, Codable {
    case farmer = "farmer"
    case buyer = "buyer"
    case transporter = "transporter"
    
    var displayName: String {
        switch self {
        case .farmer: return "Farmer"
        case .buyer: return "Buyer"
        case .transporter: return "Transporter"
        }
    }
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String?
    let role: UserRole
    let location: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, role, location
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
} 