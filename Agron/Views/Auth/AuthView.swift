import SwiftUI

struct AuthView: View {
    @State private var selectedTab = 1 // Default to Register tab for new users
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("AGRON")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Create Your Account")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Join Nigeria's Agricultural Marketplace")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Tab selector
                HStack(spacing: 0) {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = 0
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(selectedTab == 0 ? .green : .gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(selectedTab == 0 ? Color.green.opacity(0.1) : Color.clear)
                    }
                    
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = 1
                        }
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(selectedTab == 1 ? .green : .gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(selectedTab == 1 ? Color.green.opacity(0.1) : Color.clear)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(25)
                .padding(.horizontal, 30)
                
                // Tab content
                TabView(selection: $selectedTab) {
                    LoginView()
                        .tag(0)
                    
                    RegisterView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                Spacer()
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .alert("Authentication Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.clearError()
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
        .alert("Success", isPresented: .constant(authManager.successMessage != nil)) {
            Button("OK") {
                authManager.clearSuccess()
            }
        } message: {
            Text(authManager.successMessage ?? "")
        }
        .onAppear {
            // Clear any previous errors
            authManager.clearError()
            authManager.clearSuccess()
        }
    }
}

#Preview {
    AuthView()
} 