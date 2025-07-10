import SwiftUI

struct FarmerDashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var crops: [Crop] = []
    @State private var isLoading = false
    @State private var showAddCrop = false
    @State private var errorMessage: String?
    
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
                                
                                Text(authManager.currentUser?.name ?? "Farmer")
                                    .font(AppTypography.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showAddCrop = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    
                    // Quick Stats
                    if !isLoading && !crops.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.md) {
                                StatCard(
                                    icon: "leaf.fill",
                                    title: "Active Listings",
                                    value: "\(crops.filter { $0.status == .available }.count)",
                                    color: AppColors.primary
                                )
                                
                                StatCard(
                                    icon: "dollarsign.circle.fill",
                                    title: "Total Sales",
                                    value: "₦0",
                                    color: AppColors.secondary
                                )
                                
                                StatCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "This Month",
                                    value: "₦0",
                                    color: AppColors.accent
                                )
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                    
                    // Content Section
                    if isLoading {
                        VStack(spacing: AppSpacing.lg) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .foregroundColor(AppColors.primary)
                            
                            Text("Loading your crops...")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(AppSpacing.xxl)
                    } else if crops.isEmpty {
                        EmptyStateView(
                            icon: "leaf",
                            title: "No crops listed yet",
                            subtitle: "Start by adding your first crop listing to begin selling",
                            actionTitle: "Add First Crop",
                            action: {
                                showAddCrop = true
                            }
                        )
                    } else {
                        VStack(spacing: AppSpacing.md) {
                            SectionHeader("Your Crops", subtitle: "Manage your crop listings")
                            
                            LazyVStack(spacing: AppSpacing.md) {
                                ForEach(crops) { crop in
                                    ModernCropCard(crop: crop)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
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
        .sheet(isPresented: $showAddCrop) {
            AddCropView()
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
}

#Preview {
    FarmerDashboardView()
} 