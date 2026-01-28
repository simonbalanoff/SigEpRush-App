//
//  TermEditSheet.swift
//  SigEpRush-App
//
//  Sheet for editing a term
//

import SwiftUI

struct TermEditSheet: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) private var dismiss
    
    let term: TermAdminItem
    let onSaved: () -> Void
    
    @State private var name: String
    @State private var isActive: Bool
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var error: String?
    @State private var showConfirmation = false
    @State private var showInviteCode = false
    
    init(term: TermAdminItem, onSaved: @escaping () -> Void) {
        self.term = term
        self.onSaved = onSaved
        _name = State(initialValue: term.name)
        _isActive = State(initialValue: term.isActive)
    }
    
    private var hasChanges: Bool {
        name != term.name || isActive != term.isActive
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        termInfoCard
                        
                        detailsSection
                        
                        inviteCodeSection
                        
                        if let err = error {
                            errorBanner(err)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Term")
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
                        .disabled(!hasChanges || isSaving)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert("Confirm Changes", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    Task { await save() }
                }
            } message: {
                Text("Save changes to \(term.name)?")
            }
        }
    }
    
    private var termInfoCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(SigEpTheme.purple.opacity(0.12))
                Image(systemName: "calendar")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
            }
            .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text(term.name)
                    .font(.title3.weight(.semibold))
                
                Text(term.code.uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                statusBadge
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Term Details")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Term Name")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g. Fall 2025", text: $name)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .disabled(!isEditing)
                }
                
                // Active toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Active Status")
                            .font(.subheadline.weight(.medium))
                        Text("Active terms appear in member's term list")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isActive)
                        .labelsHidden()
                        .disabled(!isEditing)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }
    
    private var inviteCodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Invitation")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Invite Code")
                            .font(.subheadline.weight(.medium))
                        Text("Share this code with members to join")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showInviteCode.toggle()
                    } label: {
                        Image(systemName: showInviteCode ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(SigEpTheme.purple)
                    }
                }
                
                if showInviteCode, let code = term.inviteCode {
                    HStack {
                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = code
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SigEpTheme.purple)
                        }
                    }
                    .padding(12)
                    .background(SigEpTheme.purple.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }
    
    private var statusBadge: some View {
        Text(term.isActive ? "Active" : "Inactive")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background((term.isActive ? Color.green : Color.red).opacity(0.12))
            .foregroundStyle(term.isActive ? .green : .red)
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
    
    private func save() async {
        guard hasChanges else { return }
        
        isSaving = true
        error = nil
        defer { isSaving = false }
        
        do {
            try await api.updateTerm(termId: term.id, name: name, isActive: isActive)
            await MainActor.run {
                onSaved()
                dismiss()
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to update term. Please try again."
                isEditing = false
                name = term.name
                isActive = term.isActive
            }
        }
    }
}

#Preview("Term Edit Sheet") {
    let term = TermAdminItem(
        id: "1",
        name: "Fall 2025",
        code: "fall25",
        inviteCode: "FALL25-ABC123",
        isActive: true,
        memberCount: 15
    )
    
    let auth = AuthStore()
    auth.accessToken = "demo"
    
    let api = APIClient(auth: auth)
    
    return TermEditSheet(term: term) { }
        .environmentObject(api)
}
