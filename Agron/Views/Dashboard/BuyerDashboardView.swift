import SwiftUI

struct BuyerDashboardView: View {
    @State private var crops: [Crop] = []
    @State private var filteredCrops: [Crop] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var selectedRegion = "All"
    @State private var errorMessage: String?
    @State private var showingFilters = false
    
    private let cropTypes = ["All", "Cassava", "Rice", "Maize", "Yam", "Potato", "Tomato", "Pepper"]
    private let regions = ["All", "Lagos", "Kano", "Kaduna", "Katsina", "Oyo", "Rivers", "Jigawa", "Zamfara", "Kebbi", "Sokoto", "Yobe", "Borno", "Taraba", "Adamawa", "Bauchi", "Gombe", "Plateau", "Nasarawa", "Niger", "Kogi", "Kwara", "Ondo", "Osun", "Ogun", "Ekiti", "Edo", "Delta", "Anambra", "Imo", "Abia", "Enugu", "Ebonyi", "Cross River", "Akwa Ibom", "Bayelsa", "Abuja"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Welcome back!")
                                    .font(AppTypography.title3)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text("Find fresh crops")
                                    .font(AppTypography.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Profile or settings action
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 16))
                            
                            TextField("Search crops, farmers, or locations...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(AppTypography.body)
                                .onChange(of: searchText) { _, _ in
                                    filterCrops()
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    filterCrops()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.textTertiary)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.surface)
                        .cornerRadius(AppCornerRadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    
                    // Quick Stats
                    if !isLoading && !crops.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.md) {
                                StatCard(
                                    icon: "leaf.fill",
                                    title: "Available Crops",
                                    value: "\(crops.count)",
                                    color: AppColors.primary
                                )
                                
                                StatCard(
                                    icon: "location.fill",
                                    title: "Regions",
                                    value: "\(Set(crops.map { $0.location }).count)",
                                    color: AppColors.secondary
                                )
                                
                                StatCard(
                                    icon: "person.2.fill",
                                    title: "Farmers",
                                    value: "\(Set(crops.map { $0.farmerName }).count)",
                                    color: AppColors.primary
                                )
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                    
                    // Filters Section
                    VStack(spacing: AppSpacing.md) {
                        HStack {
                            Text("Filters")
                                .font(AppTypography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                showingFilters.toggle()
                            }) {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 14))
                                    Text("Filters")
                                        .font(AppTypography.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.primary.opacity(0.1))
                                .cornerRadius(AppCornerRadius.md)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        if showingFilters {
                            VStack(spacing: AppSpacing.md) {
                                // Type Filter
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text("Crop Type")
                                        .font(AppTypography.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: AppSpacing.sm) {
                                            ForEach(cropTypes, id: \.self) { type in
                                                FilterChip(
                                                    title: type,
                                                    isSelected: selectedType == type,
                                                    action: {
                                                        selectedType = type
                                                        filterCrops()
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }
                                
                                // Region Filter
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text("Region")
                                        .font(AppTypography.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: AppSpacing.sm) {
                                            ForEach(regions.prefix(10), id: \.self) { region in
                                                FilterChip(
                                                    title: region,
                                                    isSelected: selectedRegion == region,
                                                    action: {
                                                        selectedRegion = region
                                                        filterCrops()
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.lg)
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    
                    // Content Section
                    if isLoading {
                        VStack(spacing: AppSpacing.lg) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .foregroundColor(AppColors.primary)
                            
                            Text("Loading fresh crops...")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppSpacing.xxl)
                    } else if filteredCrops.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No crops found",
                            subtitle: "Try adjusting your search or filters to find what you're looking for",
                            actionTitle: "Clear Filters",
                            action: {
                                searchText = ""
                                selectedType = "All"
                                selectedRegion = "All"
                                filterCrops()
                            }
                        )
                    } else {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(filteredCrops) { crop in
                                NavigationLink(destination: CropDetailView(crop: crop)) {
                                    ModernCropCard(crop: crop)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
        .onAppear {
            loadCrops()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func loadCrops() {
        isLoading = true
        
        Task {
            do {
                let fetchedCrops = try await APIService.shared.getCrops()
                await MainActor.run {
                    self.crops = fetchedCrops
                    self.filteredCrops = fetchedCrops
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func filterCrops() {
        var filtered = crops
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { crop in
                crop.name.localizedCaseInsensitiveContains(searchText) ||
                crop.type.localizedCaseInsensitiveContains(searchText) ||
                crop.location.localizedCaseInsensitiveContains(searchText) ||
                crop.farmerName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by type
        if selectedType != "All" {
            filtered = filtered.filter { $0.type == selectedType }
        }
        
        // Filter by region
        if selectedRegion != "All" {
            filtered = filtered.filter { $0.location.contains(selectedRegion) }
        }
        
        filteredCrops = filtered
    }
}

// MARK: - Supporting Views

struct ModernCropCard: View {
    let crop: Crop
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Crop Image Placeholder
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text(crop.name)
                        .font(AppTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(crop.status.rawValue.capitalized, color: crop.status.color)
                }
                
                Text(crop.type)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text(crop.location)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("₦\(String(format: "%.0f", crop.price))/\(crop.unit)")
                        .font(AppTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text("by \(crop.farmerName)")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", crop.quantity)) \(crop.unit) available")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.lg)
        .shadow(color: AppShadows.small.color, radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
    }
}

#Preview {
    BuyerDashboardView()
} 
