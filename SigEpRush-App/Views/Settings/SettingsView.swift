//
//  SettingsView.swift
//  SigEpRush-App
//
//  Settings view with admin user management and term management
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var ui: AppUIState
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) private var dismiss
    
    @State private var showUserManagement = false
    @State private var showTermManagement = false
    @State private var showLogoutConfirm = false
    @State private var showDeleteAccountConfirm = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    
    private var isAdmin: Bool {
        auth.me?.role == "Admin"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        profileSection
                        
                        if isAdmin {
                            adminSection
                        }
                        
                        aboutSection
                        
                        dangerZone
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showUserManagement) {
                UserManagementView()
                    .environmentObject(auth)
                    .environmentObject(api)
            }
            .sheet(isPresented: $showTermManagement) {
                TermManagementListView()
                    .environmentObject(auth)
                    .environmentObject(api)
                    .environmentObject(ui)
            }
            .alert("Sign Out", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    auth.clear()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountConfirm) {
                Button("Cancel", role: .cancel) {
                    deleteError = nil
                }
                Button("Delete Account", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            .alert("Error", isPresented: .constant(deleteError != nil)) {
                Button("OK") {
                    deleteError = nil
                }
            } message: {
                if let error = deleteError {
                    Text(error)
                }
            }
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(SigEpTheme.purple.opacity(0.12))
                Text(initials)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
            }
            .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text(auth.me?.name ?? "Unknown")
                    .font(.title3.weight(.semibold))
                
                Text(auth.me?.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                roleBadge
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }
    
    private var adminSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Administration")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "person.3.fill",
                    title: "Manage Users",
                    subtitle: "View and edit user roles",
                    color: .orange
                ) {
                    showUserManagement = true
                }
                
                Divider().padding(.leading, 52)
                
                settingRow(
                    icon: "calendar",
                    title: "Manage Terms",
                    subtitle: "Edit and create rush terms",
                    color: .blue
                ) {
                    showTermManagement = true
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                infoRow(label: "Version", value: Bundle.main.appVersion + " (" + Bundle.main.buildNumber + ")")
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }
    
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                Button {
                    showLogoutConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.orange)
                            .frame(width: 24)
                        
                        Text("Sign Out")
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                
                Divider().padding(.leading, 52)
                
                Button {
                    showDeleteAccountConfirm = true
                } label: {
                    HStack {
                        if isDeleting {
                            ProgressView()
                                .frame(width: 24)
                        } else {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                                .frame(width: 24)
                        }
                        
                        Text("Delete Account")
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }
    
    private func settingRow(
        icon: String,
        title: String,
        subtitle: String? = nil,
        color: Color = SigEpTheme.purple,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(16)
    }
    
    private var initials: String {
        guard let name = auth.me?.name else { return "?" }
        let components = name.components(separatedBy: " ")
        let first = String(components.first?.first ?? "?")
        let last = components.count > 1 ? String(components.last?.first ?? " ") : ""
        return "\(first)\(last)".uppercased()
    }
    
    private var roleBadge: some View {
        let role = auth.me?.role ?? "Member"
        let color: Color = {
            switch role {
            case "Admin": return .orange
            case "Adder": return .blue
            default: return .gray
            }
        }()
        
        return Text(role)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
    
    private func deleteAccount() async {
        isDeleting = true
        deleteError = nil
        
        do {
            try await api.deleteAccount()
            // Account deleted successfully - clear auth and dismiss
            await MainActor.run {
                auth.clear()
                dismiss()
            }
        } catch {
            await MainActor.run {
                isDeleting = false
                deleteError = error.localizedDescription
            }
        }
    }
}

#Preview("Settings - Admin") {
    let auth = AuthStore()
    auth.accessToken = "demo"
    auth.me = Me(id: "1", name: "Admin User", role: "Admin", email: "admin@example.com")
    
    let api = APIClient(auth: auth)
    let ui = AppUIState()
    
    return SettingsView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}

#Preview("Settings - Member") {
    let auth = AuthStore()
    auth.accessToken = "demo"
    auth.me = Me(id: "2", name: "John Smith", role: "Member", email: "john@example.com")
    
    let api = APIClient(auth: auth)
    let ui = AppUIState()
    
    return SettingsView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
