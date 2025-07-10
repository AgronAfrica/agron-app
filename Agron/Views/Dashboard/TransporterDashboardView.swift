import SwiftUI

struct TransporterDashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var jobs: [DeliveryJob] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var availableJobs: [DeliveryJob] {
        jobs.filter { $0.status == .open }
    }
    
    var myJobs: [DeliveryJob] {
        jobs.filter { $0.status != .open }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(authManager.currentUser?.name ?? "Transporter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Stats cards
                HStack(spacing: 16) {
                    StatCard(
                        icon: "truck.box.fill",
                        title: "Available Jobs",
                        value: "\(availableJobs.count)",
                        color: .blue
                    )
                    
                    StatCard(
                        icon: "list.bullet",
                        title: "My Jobs",
                        value: "\(myJobs.count)",
                        color: .green
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if jobs.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "truck.box")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No delivery jobs available")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Check back later for new delivery opportunities")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Available jobs section
                            if !availableJobs.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Available Jobs")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    LazyVStack(spacing: 12) {
                                        ForEach(availableJobs) { job in
                                            JobCard(job: job) {
                                                acceptJob(job)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // My jobs section
                            if !myJobs.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("My Jobs")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    LazyVStack(spacing: 12) {
                                        ForEach(myJobs) { job in
                                            JobCard(job: job) {
                                                updateJobStatus(job)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadJobs()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func loadJobs() {
        isLoading = true
        
        Task {
            do {
                let fetchedJobs = try await APIService.shared.getJobs()
                await MainActor.run {
                    self.jobs = fetchedJobs
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
    
    private func acceptJob(_ job: DeliveryJob) {
        Task {
            do {
                let updatedJob = try await APIService.shared.acceptJob(jobId: job.id)
                await MainActor.run {
                    if let index = jobs.firstIndex(where: { $0.id == job.id }) {
                        jobs[index] = updatedJob
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateJobStatus(_ job: DeliveryJob) {
        Task {
            do {
                var updatedJob: DeliveryJob
                
                switch job.status {
                case .accepted:
                    updatedJob = try await APIService.shared.updateJobPickup(jobId: job.id)
                case .pickedUp:
                    updatedJob = try await APIService.shared.updateJobDelivered(jobId: job.id)
                default:
                    return
                }
                
                await MainActor.run {
                    if let index = jobs.firstIndex(where: { $0.id == job.id }) {
                        jobs[index] = updatedJob
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct JobCard: View {
    let job: DeliveryJob
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.cropName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Order #\(job.orderNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(job.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(job.status.color).opacity(0.2))
                    .foregroundColor(Color(job.status.color))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    Text("Pickup: \(job.pickupLocation)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                    Text("Delivery: \(job.deliveryLocation)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "cube.box.fill")
                        .foregroundColor(.orange)
                    Text("\(job.quantity, specifier: "%.1f") \(job.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if job.status == .open {
                Button(action: action) {
                    Text("Accept Job")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.green)
                        .cornerRadius(20)
                }
            } else if job.status == .accepted {
                Button(action: action) {
                    Text("Confirm Pickup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            } else if job.status == .pickedUp {
                Button(action: action) {
                    Text("Confirm Delivery")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.green)
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    TransporterDashboardView()
} 