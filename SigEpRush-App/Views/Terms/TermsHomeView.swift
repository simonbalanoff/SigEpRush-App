//
//  TermsHomeView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct TermsHomeView: View {
    @EnvironmentObject var api: APIClient
    @State private var terms: [TermSummary] = []
    @State private var loading = true
    @State private var showJoin = false
    @State private var selected: TermSummary?

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    LoadingOverlay()
                } else if terms.isEmpty {
                    EmptyStateView(title: "No Terms", message: "Join a term to get started.") {
                        showJoin = true
                    }
                } else {
                    List {
                        ForEach(terms) { t in
                            Button {
                                selected = t
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(t.name).font(.headline)
                                        Text(t.code).foregroundStyle(.secondary).font(.subheadline)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rush Terms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showJoin = true } label: { Image(systemName: "folder.badge.plus") }
                }
            }
            .toolbarSettingsButton()
            .task {
                loading = true
                defer { loading = false }
                do { terms = try await api.myTerms() } catch {}
            }
            .fullScreenCover(isPresented: $showJoin) {
                JoinTermView { _ in
                    Task { do { terms = try await api.myTerms() } catch {} }
                }
            }
            .navigationDestination(item: $selected) { t in
                TermWorkspaceView(term: t)
            }
        }
    }
}
