import SwiftUI

struct MainDashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            Group {
                switch authManager.currentUser?.role {
                case .farmer:
                    FarmerDashboardView()
                case .buyer:
                    BuyerDashboardView()
                case .transporter:
                    TransporterDashboardView()
                case nil:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.background)
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Orders tab
            OrdersView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .tag(1)
            
            // Profile tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(AppColors.primary)
        .background(AppColors.background)
    }
}

#Preview {
    MainDashboardView()
} 