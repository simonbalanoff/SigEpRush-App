//
//  CreateTermSheet.swift
//  SigEpRush-App
//
//  Sheet for creating a new term
//

import SwiftUI

struct CreateTermSheet: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) private var dismiss
    
    let onCreated: () -> Void
    
    @State private var name = ""
    @State private var code = ""
    @State private var invitationCode = ""
    @State private var isCreating = false
    @State private var error: String?
    
    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        code.count >= 3 &&
        !invitationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        invitationCode.count >= 6 &&
        !isCreating
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        
                        formSection
                        
                        if let err = error {
                            errorBanner(err)
                        }
                        
                        createButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Term")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(SigEpTheme.purple.opacity(0.12))
                Image(systemName: "calendar.badge.plus")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
            }
            .frame(width: 80, height: 80)
            
            Text("New Rush Term")
                .font(.title3.weight(.semibold))
            
            Text("Create a new rush term for your chapter")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Term Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Term Name")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("e.g. Fall 2025", text: $name)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(SigEpTheme.purple.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Term Code
            VStack(alignment: .leading, spacing: 8) {
                Text("Term Code")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("e.g. F25 (min 3 characters)", text: $code)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(SigEpTheme.purple.opacity(0.3), lineWidth: 1)
                    )
                
                Text("Short identifier for this term")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Invitation Code
            VStack(alignment: .leading, spacing: 8) {
                Text("Invitation Code")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("e.g. FALL25-RUSH (min 6 characters)", text: $invitationCode)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(SigEpTheme.purple.opacity(0.3), lineWidth: 1)
                    )
                
                Text("Members will use this code to join the term")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }
    
    private var createButton: some View {
        Button {
            Task { await create() }
        } label: {
            HStack(spacing: 8) {
                if isCreating {
                    ProgressView()
                        .tint(.white)
                }
                Text(isCreating ? "Creating..." : "Create Term")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(canSubmit ? SigEpTheme.purple : SigEpTheme.purple.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: canSubmit ? SigEpTheme.purple.opacity(0.3) : .clear,
                radius: 8, y: 4
            )
        }
        .disabled(!canSubmit)
        .padding(.top, 8)
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
    
    private func create() async {
        guard canSubmit else { return }
        
        isCreating = true
        error = nil
        defer { isCreating = false }
        
        do {
            let req = CreateTermReq(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                code: code.trimmingCharacters(in: .whitespacesAndNewlines),
                inviteCode: invitationCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            _ = try await api.createTerm(req)
            await MainActor.run {
                onCreated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to create term. The code may already be in use."
            }
        }
    }
}

#Preview("Create Term Sheet") {
    let auth = AuthStore()
    auth.accessToken = "demo"
    
    let api = APIClient(auth: auth)
    
    return CreateTermSheet { }
        .environmentObject(api)
}
