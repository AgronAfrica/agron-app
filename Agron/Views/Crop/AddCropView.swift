import SwiftUI

struct AddCropView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var type = ""
    @State private var quantity = ""
    @State private var unit = "kg"
    @State private var price = ""
    @State private var currency = "₦"
    @State private var location = ""
    @State private var availabilityDate = Date()
    @State private var description = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let units = ["kg", "tons", "bags", "pieces"]
    private let currencies = ["₦", "$", "€", "£"]
    private let cropTypes = ["Cassava", "Rice", "Maize", "Yam", "Potato", "Tomato", "Pepper", "Other"]
    
    private var isFormValid: Bool {
        !name.isEmpty && !type.isEmpty && !quantity.isEmpty && 
        !price.isEmpty && !location.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        // Crop name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Crop Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter crop name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Crop type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Crop Type")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Type", selection: $type) {
                                Text("Select type").tag("")
                                ForEach(cropTypes, id: \.self) { cropType in
                                    Text(cropType).tag(cropType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Quantity and unit
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quantity")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("0.0", text: $quantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Picker("Unit", selection: $unit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Price and currency
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Price")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("0.00", text: $price)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Currency")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Picker("Currency", selection: $currency) {
                                    ForEach(currencies, id: \.self) { currency in
                                        Text(currency).tag(currency)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter location", text: $location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Availability date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Availability Date")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            DatePicker("", selection: $availabilityDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Submit button
                    Button(action: {
                        createCrop()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("List Crop")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isLoading || !isFormValid ? 0.6 : 1.0)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Add New Crop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func createCrop() {
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: availabilityDate)
        
        let cropRequest = CropCreateRequest(
            name: name,
            type: type,
            quantity: Double(quantity) ?? 0,
            unit: unit,
            price: Double(price) ?? 0,
            currency: currency,
            location: location,
            availabilityDate: dateString,
            description: description.isEmpty ? nil : description
        )
        
        Task {
            do {
                let _ = try await APIService.shared.createCrop(crop: cropRequest)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AddCropView()
} 