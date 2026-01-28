//
//  UserEditSheet.swift
//  SigEpRush-App
//
//  Sheet for editing a user's role
//

import SwiftUI

struct UserEditSheet: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) private var dismiss
    
    let user: UserListItem
    let onSaved: () -> Void
    
    @State private var selectedRole: String
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var error: String?
    @State private var showConfirmation = false
    
    private let roles = ["Member", "Adder", "Admin"]
    
    init(user: UserListItem, onSaved: @escaping () -> Void) {
        self.user = user
        self.onSaved = onSaved
        _selectedRole = State(initialValue: user.role)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        userInfoCard
                        
                        roleSection
                        
                        if let err = error {
                            errorBanner(err)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            showConfirmation = true
                        }
                        .fontWeight(.semibold)
                        .disabled(selectedRole == user.role || isSaving)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert("Confirm Role Change", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    Task { await saveRole() }
                }
            } message: {
                Text("Change \(user.name)'s role from \(user.role) to \(selectedRole)?")
            }
        }
    }
    
    private var userInfoCard: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(SigEpTheme.purple.opacity(0.12))
                Text(initials)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
            }
            .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title3.weight(.semibold))
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !user.isActive {
                    Text("Inactive User")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }
    
    private var roleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("User Role")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if isEditing {
                    Text("Tap to select")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(roles, id: \.self) { role in
                    roleButton(role)
                }
            }
            
            if isEditing {
                roleDescriptions
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }
    
    private func roleButton(_ role: String) -> some View {
        Button {
            if isEditing {
                selectedRole = role
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            selectedRole == role ? SigEpTheme.purple : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if selectedRole == role {
                        Circle()
                            .fill(SigEpTheme.purple)
                            .frame(width: 14, height: 14)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(role)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text(roleDescription(role))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                roleBadge(role)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedRole == role ? SigEpTheme.purple.opacity(0.06) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        selectedRole == role ? SigEpTheme.purple.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEditing)
    }
    
    private var roleDescriptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Role Descriptions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                roleDescriptionRow("Member", "Can view PNMs and add ratings")
                roleDescriptionRow("Adder", "Can add/edit PNMs and manage term settings")
                roleDescriptionRow("Admin", "Full access to all features and user management")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func roleDescriptionRow(_ role: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
            VStack(alignment: .leading, spacing: 2) {
                Text(role)
                    .fontWeight(.medium)
                Text(description)
            }
        }
    }
    
    private func roleDescription(_ role: String) -> String {
        switch role {
        case "Admin": return "Full access"
        case "Adder": return "Can add PNMs"
        case "Member": return "View & rate only"
        default: return ""
        }
    }
    
    private func roleBadge(_ role: String) -> some View {
        let color: Color = {
            switch role {
            case "Admin": return .orange
            case "Adder": return .blue
            default: return .gray
            }
        }()
        
        return Text(role)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var initials: String {
        let components = user.name.components(separatedBy: " ")
        let first = String(components.first?.first ?? "?")
        let last = components.count > 1 ? String(components.last?.first ?? " ") : ""
        return "\(first)\(last)".uppercased()
    }
    
    private func saveRole() async {
        guard selectedRole != user.role else { return }
        
        isSaving = true
        error = nil
        defer { isSaving = false }
        
        do {
            try await api.updateUserRole(userId: user.id, role: selectedRole)
            await MainActor.run {
                onSaved()
                dismiss()
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to update role. Please try again."
                isEditing = false
                selectedRole = user.role
            }
        }
    }
}

#Preview("User Edit Sheet") {
    let user = UserListItem(
        id: "1",
        name: "John Smith",
        email: "john@example.com",
        role: "Member",
        isActive: true,
        createdAt: nil
    )
    
    let auth = AuthStore()
    auth.accessToken = "demo"
    
    let api = APIClient(auth: auth)
    
    return UserEditSheet(user: user) { }
        .environmentObject(api)
}
