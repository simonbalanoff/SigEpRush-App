//
//  ManageTermsView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct ManageTermsView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var ui: AppUIState

    @State private var items: [TermAdminItem] = []
    @State private var loading = true
    @State private var error: String?

    var body: some View {
        List {
            if let e = error { Text(e).foregroundStyle(.red) }
            ForEach($items) { $t in
                HStack {
                    VStack(alignment: .leading) {
                        Text(t.name).font(.headline)
                        Text(t.code).foregroundStyle(.secondary).font(.subheadline)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { t.isActive },
                        set: { newVal in
                            let old = t.isActive
                            t.isActive = newVal
                            Task {
                                do {
                                    try await api.setTermActive(termId: t.id, active: newVal)
                                    await MainActor.run {
                                        ui.termsRefreshKey = UUID()
                                    }
                                } catch {
                                    await MainActor.run {
                                        t.isActive = old
                                    }
                                }
                            }
                        }
                    ))
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Manage Terms")
        .task {
            loading = true
            defer { loading = false }
            do { items = try await api.adminTerms() } catch { self.error = "Failed to load terms" }
        }
        .refreshable {
            do { items = try await api.adminTerms() } catch {}
        }
    }
}
