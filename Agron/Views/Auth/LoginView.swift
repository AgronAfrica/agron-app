import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var emailError = ""
    @State private var passwordError = ""
    @StateObject private var authManager = AuthManager.shared
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError.isEmpty && passwordError.isEmpty
    }
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            emailError = "Email is required"
        } else if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
        } else if password.count > 128 {
            passwordError = "Password cannot exceed 128 characters"
        } else {
            passwordError = ""
        }
    }
    
    private func handleLogin() {
        validateEmail()
        validatePassword()
        
        if isFormValid {
            Task {
                await authManager.login(email: email, password: password)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) { _, _ in
                            if !emailError.isEmpty {
                                validateEmail()
                            }
                        }
                        .onSubmit {
                            validateEmail()
                        }
                    
                    if !emailError.isEmpty {
                        Text(emailError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: password) { _, _ in
                        if !passwordError.isEmpty {
                            validatePassword()
                        }
                    }
                    .onSubmit {
                        validatePassword()
                    }
                    
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            // Login button
            Button(action: handleLogin) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Login")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? Color.green : Color.gray)
                .cornerRadius(25)
            }
            .disabled(authManager.isLoading || !isFormValid)
            .opacity(authManager.isLoading || !isFormValid ? 0.6 : 1.0)
            .padding(.horizontal, 30)
            
            // Forgot password
            Button(action: {
                // TODO: Implement forgot password
            }) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            // Clear any previous errors
            emailError = ""
            passwordError = ""
        }
    }
}

#Preview {
    LoginView()
} 