import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let _ = KeychainService.shared.getToken(),
           let user = KeychainService.shared.getUser() {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func login(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            
            await MainActor.run {
                if KeychainService.shared.saveToken(response.token) &&
                   KeychainService.shared.saveUser(response.user) {
                    self.currentUser = response.user
                    self.isAuthenticated = true
                    self.successMessage = "Login successful! Welcome back, \(response.user.name)"
                } else {
                    self.errorMessage = "Failed to save authentication data. Please try again."
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = self.formatErrorMessage(error)
                self.isLoading = false
            }
        }
    }
    
    func register(name: String, email: String, password: String, phone: String?, role: UserRole, location: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        
        do {
            let response = try await APIService.shared.register(name: name, email: email, password: password, phone: phone, role: role, location: location)
            
            await MainActor.run {
                if KeychainService.shared.saveToken(response.token) &&
                   KeychainService.shared.saveUser(response.user) {
                    self.currentUser = response.user
                    self.isAuthenticated = true
                    self.successMessage = "Account created successfully! Welcome to Agron, \(response.user.name)"
                } else {
                    self.errorMessage = "Failed to save authentication data. Please try again."
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = self.formatErrorMessage(error)
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        KeychainService.shared.clearAll()
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
        successMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    private func formatErrorMessage(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "Invalid URL. Please check your connection."
            case .invalidResponse:
                return "Invalid response from server. Please try again."
            case .serverError(let message):
                return message.isEmpty ? "Server error. Please try again." : message
            }
        } else {
            return error.localizedDescription
        }
    }
} 
