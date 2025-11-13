//
//  TermsHomeView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

enum TermLayoutMode: String, CaseIterable, Identifiable {
    case list
    case grid
    var id: Self { self }
}

struct TermsHomeView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var ui: AppUIState

    @State private var terms: [TermSummary] = []
    @State private var loading = true
    @State private var showJoin = false
    @State private var selected: TermSummary?
    @State private var search = ""
    @State private var layoutMode: TermLayoutMode = .list

    var filteredTerms: [TermSummary] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return terms }
        let q = trimmed.lowercased()
        return terms.filter { t in
            t.name.lowercased().contains(q) || t.code.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("Search terms", text: $search)
                        .textFieldStyle(.roundedBorder)
                    HStack(spacing: 8) {
                        layoutIcon(mode: .list, systemName: "list.bullet")
                        layoutIcon(mode: .grid, systemName: "square.grid.2x2")
                    }
                }
                .padding(.horizontal)

                Group {
                    if loading {
                        LoadingOverlay()
                    } else if filteredTerms.isEmpty {
                        if terms.isEmpty {
                            EmptyStateView(
                                title: "No Terms",
                                message: "Join a term to get started."
                            ) {
                                showJoin = true
                            }
                        } else {
                            EmptyStateView(
                                title: "No Matches",
                                message: "Try a different search."
                            )
                        }
                    } else {
                        switch layoutMode {
                        case .list:
                            listView
                        case .grid:
                            gridView
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Rush Terms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showJoin = true } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .toolbarSettingsButton()
            .task(id: ui.termsRefreshKey) {
                await loadTerms()
            }
            .sheet(isPresented: $showJoin) {
                JoinTermView { _ in
                    Task { await loadTerms() }
                }
                .environmentObject(api)
            }
            .navigationDestination(item: $selected) { t in
                TermWorkspaceView(term: t)
            }
        }
    }

    func layoutIcon(mode: TermLayoutMode, systemName: String) -> some View {
        Button {
            layoutMode = mode
        } label: {
            Image(systemName: systemName)
                .imageScale(.medium)
                .padding(8)
                .background(layoutMode == mode ? Color.gray.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    var listView: some View {
        List {
            ForEach(filteredTerms) { t in
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
        .listStyle(.plain)
    }

    var gridView: some View {
        ScrollView {
            let cols = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(filteredTerms) { t in
                    Button {
                        selected = t
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t.name)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text(t.code)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }

    func loadTerms() async {
        loading = true
        defer { loading = false }
        do {
            let all = try await api.myTerms()
            terms = all.filter { $0.active }
        } catch {}
    }
}
