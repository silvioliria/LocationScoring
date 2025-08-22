import SwiftUI
import SwiftData

struct UserProfileView: View {
    @ObservedObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Profile Header
                VStack(spacing: 20) {
                    // Profile Image
                    if let profileImageURL = authService.currentUser?.profileImageURL,
                       let url = URL(string: profileImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                    }
                    
                    // User Name
                    Text(authService.currentUser?.name ?? "Unknown User")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // User Email
                    Text(authService.currentUser?.email ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // User Details
                VStack(spacing: 20) {
                    DetailRow(title: "Name", value: authService.currentUser?.name ?? "N/A")
                    DetailRow(title: "Email", value: authService.currentUser?.email ?? "N/A")
                    DetailRow(title: "Phone", value: authService.currentUser?.phone ?? "Not provided")
                    DetailRow(title: "Member Since", value: formatDate(authService.currentUser?.createdAt))
                    DetailRow(title: "Last Login", value: formatDate(authService.currentUser?.lastLoginDate))
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    authService.signOut()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(25)
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    let authService = AuthenticationService()
    
    // Create a sample user for preview
    let user = User(id: "123", name: "John Doe", email: "john@example.com", phone: "+1-555-0123")
    
    UserProfileView(authService: authService)
        .onAppear {
            authService.currentUser = user
            authService.isAuthenticated = true
        }
}
