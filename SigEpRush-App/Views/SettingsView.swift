//
//  SettingsView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthStore
    var body: some View {
        Form {
            Section {
                if let me = auth.me {
                    Text(me.name)
                    Text(me.email).foregroundStyle(.secondary)
                    Text(me.role).foregroundStyle(.secondary)
                }
            }
            Section {
                Button("Sign out") { auth.clear() }.foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
}
