//
//  UserManagementView.swift
//  SigEpRush-App
//
//  Admin-only user management interface
//

import SwiftUI

struct UserManagementView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var users: [UserListItem] = []
    @State private var searchQuery = ""
    @State private var loading = true
    @State private var selectedUser: UserListItem?
    @State private var error: String?
    
    private var filteredUsers: [UserListItem] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return users }
        let q = trimmed.lowercased()
        
        return users.filter { u in
            u.name.lowercased().contains(q) ||
            u.email.lowercased().contains(q) ||
            u.role.lowercased().contains(q)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    searchBar
                    
                    if loading {
                        LoadingOverlay()
                    } else if let err = error {
                        errorView(err)
                    } else if filteredUsers.isEmpty {
                        emptyState
                    } else {
                        usersList
                    }
                }
            }
            .navigationTitle("Manage Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadUsers()
            }
            .sheet(item: $selectedUser) { user in
                UserEditSheet(user: user) {
                    Task { await loadUsers() }
                }
                .environmentObject(api)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search users by name or email", text: $searchQuery)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SigEpTheme.purple.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredUsers) { user in
                    Button {
                        selectedUser = user
                    } label: {
                        UserRowView(user: user)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Users Found")
                .font(.headline)
            Text("Try adjusting your search.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            Text("Error")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task { await loadUsers() }
            }
            .buttonStyle(.borderedProminent)
            .tint(SigEpTheme.purple)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func loadUsers() async {
        loading = true
        error = nil
        defer { loading = false }
        
        do {
            users = try await api.listUsers()
        } catch {
            self.error = "Failed to load users. Please try again."
        }
    }
}

struct UserRowView: View {
    let user: UserListItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(SigEpTheme.purple.opacity(0.12))
                Text(initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                roleBadge
                
                if !user.isActive {
                    Text("Inactive")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 1)
    }
    
    private var initials: String {
        let components = user.name.components(separatedBy: " ")
        let first = String(components.first?.first ?? "?")
        let last = components.count > 1 ? String(components.last?.first ?? " ") : ""
        return "\(first)\(last)".uppercased()
    }
    
    private var roleBadge: some View {
        let color: Color = {
            switch user.role {
            case "Admin": return .orange
            case "Adder": return .blue
            default: return .gray
            }
        }()
        
        return Text(user.role)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview("User Management") {
    let auth = AuthStore()
    auth.accessToken = "demo"
    auth.me = Me(id: "1", name: "Admin User", role: "Admin", email: "admin@example.com")
    
    let api = APIClient(auth: auth)
    
    return UserManagementView()
        .environmentObject(api)
        .environmentObject(auth)
}
