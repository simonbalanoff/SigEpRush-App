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

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(auth.me?.name ?? "-").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(auth.me?.email ?? "-").foregroundStyle(.secondary)
                    }
                    Button("Sign Out") { auth.clear() }.tint(.red)
                }
                Section("Terms") {
                    Button {
                        ui.showCreateTerm = true
                    } label: {
                        Label("Create Term", systemImage: "folder.badge.plus")
                    }
                    NavigationLink {
                        ManageTermsView()
                    } label: {
                        Label("Manage Terms", systemImage: "folder.badge.gear")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } } }
            .fullScreenCover(isPresented: $ui.showCreateTerm) { CreateTermModal() }
        }
    }
}
