import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .farmer
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var nameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @StateObject private var authManager = AuthManager.shared
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 8 &&
        nameError.isEmpty && emailError.isEmpty && passwordError.isEmpty && confirmPasswordError.isEmpty
    }
    
    private func validateName() {
        if name.isEmpty {
            nameError = "Name is required"
        } else if name.count < 2 {
            nameError = "Name must be at least 2 characters"
        } else if name.count > 50 {
            nameError = "Name cannot exceed 50 characters"
        } else {
            nameError = ""
        }
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
    
    private func validatePhone() {
        if !phone.isEmpty {
            let phoneRegex = "^[0-9+]{10,15}$"
            let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
            
            if !phonePredicate.evaluate(with: phone) {
                phoneError = "Please enter a valid phone number"
            } else {
                phoneError = ""
            }
        } else {
            phoneError = ""
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
        } else if password.count > 128 {
            passwordError = "Password cannot exceed 128 characters"
        } else {
            passwordError = ""
        }
        
        // Also validate confirm password when password changes
        if !confirmPassword.isEmpty {
            validateConfirmPassword()
        }
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = ""
        }
    }
    
    private func handleRegister() {
        validateName()
        validateEmail()
        validatePhone()
        validatePassword()
        validateConfirmPassword()
        
        if isFormValid {
            Task {
                await authManager.register(
                    name: name,
                    email: email,
                    password: password,
                    phone: phone.isEmpty ? nil : phone,
                    role: selectedRole,
                    location: location.isEmpty ? nil : location
                )
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: name) { _, _ in
                                if !nameError.isEmpty {
                                    validateName()
                                }
                            }
                            .onSubmit {
                                validateName()
                            }
                        
                        if !nameError.isEmpty {
                            Text(nameError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
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
                    
                    // Phone field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your phone number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                            .onChange(of: phone) { _, _ in
                                if !phoneError.isEmpty {
                                    validatePhone()
                                }
                            }
                            .onSubmit {
                                validatePhone()
                            }
                        
                        if !phoneError.isEmpty {
                            Text(phoneError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Location field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your location", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: location) { _, _ in
                                // No specific validation for location yet
                            }
                            .onSubmit {
                                // No specific validation for location yet
                            }
                    }
                    
                    // Role selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("I am a")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Role", selection: $selectedRole) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                Text(role.displayName).tag(role)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
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
                    
                    // Confirm password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm your password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm your password", text: $confirmPassword)
                            }
                            
                            Button(action: {
                                showConfirmPassword.toggle()
                            }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: confirmPassword) { _, _ in
                            if !confirmPasswordError.isEmpty {
                                validateConfirmPassword()
                            }
                        }
                        .onSubmit {
                            validateConfirmPassword()
                        }
                        
                        if !confirmPasswordError.isEmpty {
                            Text(confirmPasswordError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                // Register button
                Button(action: handleRegister) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create Account")
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
                
                Spacer(minLength: 50)
            }
            .padding(.top, 20)
        }
        .onAppear {
            // Clear any previous errors
            nameError = ""
            emailError = ""
            phoneError = ""
            passwordError = ""
            confirmPasswordError = ""
            
            // Pre-select the role from onboarding if available
            if let savedRoleString = UserDefaults.standard.string(forKey: "selectedRole"),
               let savedRole = UserRole(rawValue: savedRoleString) {
                selectedRole = savedRole
            }
        }
    }
}

#Preview {
    RegisterView()
} 