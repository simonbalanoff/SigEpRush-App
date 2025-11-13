//
//  SettingsView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var ui: AppUIState
    @Environment(\.dismiss) var dismiss

    @State private var showLogoutConfirm = false

    private var canManageTerms: Bool {
        auth.me?.role == "Admin" || auth.me?.role == "Adder"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    header

                    ScrollView {
                        VStack(spacing: 16) {
                            accountCard
                            if canManageTerms {
                                termsCard
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .alert("Sign Out", isPresented: $showLogoutConfirm) {
                Button("Sign Out", role: .destructive) {
                    performLogout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                ui.showSettings = false
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(SigEpTheme.purple)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            }

            Image("SigEpCrest")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("SigEp Rush")
                    .font(.headline.weight(.semibold))
                Text("Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                settingsRow(label: "Name", value: auth.me?.name ?? "-")
                Divider()
                settingsRow(label: "Email", value: auth.me?.email ?? "-")
                Divider()
                settingsRow(label: "Role", value: auth.me?.role ?? "-")
                Divider()
                signOutRow
            }
            .padding(.horizontal, 24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }

    private func settingsRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
    
    private var signOutRow: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            HStack {
                Text("Sign Out")
                    .foregroundStyle(.red)
                Spacer()
            }
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var termsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terms")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                NavigationLink {
                    CreateTermView()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "folder.badge.plus")
                            .imageScale(.medium)
                            .foregroundStyle(SigEpTheme.purple)
                        Text("Create Term")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Divider()

                NavigationLink {
                    ManageTermsView()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "folder.badge.gear")
                            .imageScale(.medium)
                            .foregroundStyle(SigEpTheme.purple)
                        Text("Manage Terms")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }

    private func performLogout() {
        auth.clear()
        ui.showSettings = false
        dismiss()
    }
}

#Preview {
    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)
    let ui = AppUIState()

    return SettingsView()
        .environmentObject(api)
        .environmentObject(auth)
        .environmentObject(ui)
}
