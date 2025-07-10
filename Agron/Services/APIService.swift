import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    private let baseURL = "https://agron-backend-869341752067.us-central1.run.app/api"
    
    private init() {}
    
    // MARK: - Authentication
    func register(name: String, email: String, password: String, phone: String?, role: UserRole, location: String? = nil) async throws -> AuthResponse {
        var body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "password_confirmation": password, // Add password confirmation
            "phone": phone ?? "",
            "role": role.rawValue
        ]
        
        // Add location if provided
        if let location = location, !location.isEmpty {
            body["location"] = location
        }
        
        return try await makeRequest(endpoint: "/register", method: "POST", body: body)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        return try await makeRequest(endpoint: "/login", method: "POST", body: body)
    }
    
    func getUser() async throws -> User {
        return try await makeRequest(endpoint: "/user", method: "GET")
    }
    
    // MARK: - Crops
    func createCrop(crop: CropCreateRequest) async throws -> Crop {
        return try await makeRequest(endpoint: "/crops", method: "POST", body: crop.dictionary)
    }
    
    func getCrops(type: String? = nil, region: String? = nil) async throws -> [Crop] {
        var queryItems: [String] = []
        if let type = type { queryItems.append("type=\(type)") }
        if let region = region { queryItems.append("region=\(region)") }
        
        let query = queryItems.isEmpty ? "" : "?\(queryItems.joined(separator: "&"))"
        return try await makeRequest(endpoint: "/crops\(query)", method: "GET")
    }
    
    func updateCrop(id: Int, crop: CropUpdateRequest) async throws -> Crop {
        return try await makeRequest(endpoint: "/crops/\(id)", method: "PUT", body: crop.dictionary)
    }
    
    func deleteCrop(id: Int) async throws {
        let _: EmptyResponse = try await makeRequest(endpoint: "/crops/\(id)", method: "DELETE")
    }
    
    // MARK: - Orders
    func createOrder(order: OrderCreateRequest) async throws -> Order {
        return try await makeRequest(endpoint: "/orders", method: "POST", body: order.dictionary)
    }
    
    func getUserOrders() async throws -> [Order] {
        return try await makeRequest(endpoint: "/orders/user", method: "GET")
    }
    
    func updateOrderStatus(id: Int, status: OrderStatus) async throws -> Order {
        let body: [String: Any] = ["status": status.rawValue]
        return try await makeRequest(endpoint: "/orders/\(id)/status", method: "PATCH", body: body)
    }
    
    // MARK: - Delivery Jobs
    func getJobs() async throws -> [DeliveryJob] {
        return try await makeRequest(endpoint: "/jobs", method: "GET")
    }
    
    func acceptJob(jobId: Int) async throws -> DeliveryJob {
        return try await makeRequest(endpoint: "/jobs/accept", method: "POST", body: ["job_id": jobId])
    }
    
    func updateJobPickup(jobId: Int) async throws -> DeliveryJob {
        return try await makeRequest(endpoint: "/jobs/\(jobId)/pickup", method: "PATCH")
    }
    
    func updateJobDelivered(jobId: Int) async throws -> DeliveryJob {
        return try await makeRequest(endpoint: "/jobs/\(jobId)/delivered", method: "PATCH")
    }
    
    // MARK: - Generic Request Method
    private func makeRequest<T: Codable>(endpoint: String, method: String, body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Set timeout to 30 seconds
        
        // Add auth token if available
        if let token = KeychainService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        print("🌐 API Request: \(method) \(url)")
        if let body = body {
            print("📦 Request Body: \(body)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            
            if httpResponse.statusCode >= 400 {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                let errorMessage = errorResponse?.message ?? "Server error (Status: \(httpResponse.statusCode))"
                print("❌ API Error: \(errorMessage)")
                throw APIError.serverError(errorMessage)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                print("✅ API Success: \(endpoint)")
                return decodedResponse
            } catch {
                print("❌ Decoding Error: \(error)")
                throw APIError.serverError("Failed to decode response")
            }
        } catch let urlError as URLError {
            print("❌ Network Error: \(urlError.localizedDescription)")
            switch urlError.code {
            case .notConnectedToInternet:
                throw APIError.serverError("No internet connection. Please check your network.")
            case .timedOut:
                throw APIError.serverError("Request timed out. Please try again.")
            case .cannotFindHost:
                throw APIError.serverError("Cannot connect to server. Please check your connection.")
            default:
                throw APIError.serverError("Network error: \(urlError.localizedDescription)")
            }
        } catch {
            print("❌ Unexpected Error: \(error)")
            throw APIError.serverError("An unexpected error occurred. Please try again.")
        }
    }
}

// MARK: - Supporting Types
struct CropCreateRequest {
    let name: String
    let type: String
    let quantity: Double
    let unit: String
    let price: Double
    let currency: String
    let location: String
    let availabilityDate: String
    let description: String?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "type": type,
            "quantity": quantity,
            "unit": unit,
            "price": price,
            "currency": currency,
            "location": location,
            "availability_date": availabilityDate
        ]
        if let description = description {
            dict["description"] = description
        }
        return dict
    }
}

struct CropUpdateRequest {
    let name: String?
    let type: String?
    let quantity: Double?
    let unit: String?
    let price: Double?
    let currency: String?
    let location: String?
    let availabilityDate: String?
    let description: String?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        if let name = name { dict["name"] = name }
        if let type = type { dict["type"] = type }
        if let quantity = quantity { dict["quantity"] = quantity }
        if let unit = unit { dict["unit"] = unit }
        if let price = price { dict["price"] = price }
        if let currency = currency { dict["currency"] = currency }
        if let location = location { dict["location"] = location }
        if let availabilityDate = availabilityDate { dict["availability_date"] = availabilityDate }
        if let description = description { dict["description"] = description }
        return dict
    }
}

struct OrderCreateRequest {
    let cropId: Int
    let quantity: Double
    let pickupLocation: String
    let deliveryLocation: String?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "crop_id": cropId,
            "quantity": quantity,
            "pickup_location": pickupLocation
        ]
        if let deliveryLocation = deliveryLocation {
            dict["delivery_location"] = deliveryLocation
        }
        return dict
    }
}

struct ErrorResponse: Codable {
    let message: String
}

struct EmptyResponse: Codable {}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        }
    }
} 