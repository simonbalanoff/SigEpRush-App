//
//  TermManagementListView.swift
//  SigEpRush-App
//
//  Admin term management list interface
//

import SwiftUI

struct TermManagementListView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var ui: AppUIState
    @Environment(\.dismiss) private var dismiss
    
    @State private var terms: [TermAdminItem] = []
    @State private var loading = true
    @State private var error: String?
    @State private var selectedTerm: TermAdminItem?
    @State private var showCreateTerm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    if loading {
                        LoadingOverlay()
                    } else if let err = error {
                        errorView(err)
                    } else if terms.isEmpty {
                        emptyState
                    } else {
                        termsList
                    }
                }
            }
            .navigationTitle("Manage Terms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateTerm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(SigEpTheme.purple)
                    }
                }
            }
            .task {
                await loadTerms()
            }
            .sheet(item: $selectedTerm) { term in
                TermEditSheet(term: term) {
                    Task {
                        await loadTerms()
                        ui.termsRefreshKey = UUID()
                    }
                }
                .environmentObject(api)
            }
            .sheet(isPresented: $showCreateTerm) {
                CreateTermSheet {
                    Task {
                        await loadTerms()
                        ui.termsRefreshKey = UUID()
                    }
                }
                .environmentObject(api)
            }
        }
    }
    
    private var termsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(terms) { term in
                    Button {
                        selectedTerm = term
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(term.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                HStack(spacing: 8) {
                                    Text(term.code.uppercased())
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    if let count = term.memberCount {
                                        Text("•")
                                            .foregroundStyle(.secondary)
                                        
                                        Text("\(count) members")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                if term.isActive {
                                    Text("Active")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.12))
                                        .foregroundStyle(.green)
                                        .clipShape(Capsule())
                                } else {
                                    Text("Inactive")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.12))
                                        .foregroundStyle(.red)
                                        .clipShape(Capsule())
                                }
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 1)
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
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Terms Yet")
                .font(.headline)
            Text("Create your first rush term to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showCreateTerm = true
            } label: {
                Text("Create Term")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(SigEpTheme.purple)
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
        .padding()
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
                Task { await loadTerms() }
            }
            .buttonStyle(.borderedProminent)
            .tint(SigEpTheme.purple)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func loadTerms() async {
        loading = true
        error = nil
        defer { loading = false }
        
        do {
            terms = try await api.adminTerms()
        } catch {
            self.error = "Failed to load terms. Please try again."
        }
    }
}

#Preview("Term Management List") {
    let auth = AuthStore()
    auth.accessToken = "demo"
    auth.me = Me(id: "1", name: "Admin User", role: "Admin", email: "admin@example.com")
    
    let api = APIClient(auth: auth)
    let ui = AppUIState()
    
    return TermManagementListView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
