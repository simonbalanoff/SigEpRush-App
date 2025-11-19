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
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            Image("SigEpCrest")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("SigEp Rush")
                                    .font(.headline.weight(.semibold))
                                Text("Terms")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            
                            HStack(spacing: 8) {
                                layoutIcon(mode: .list, systemName: "list.bullet")

                                layoutIcon(mode: .grid, systemName: "square.grid.2x2")

                                Button {
                                    showJoin = true
                                } label: {
                                    Image(systemName: "plus")
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

                                Button {
                                    ui.showSettings = true
                                } label: {
                                    Image(systemName: "gearshape.fill")
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
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                TextField("Search terms", text: $search)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(SigEpTheme.purple.opacity(0.3), lineWidth: 1)
                            )
                            .frame(maxWidth: .infinity)

                            
                        }
                        .padding(.horizontal)
                    }

                    Group {
                        if loading {
                            LoadingOverlay()
                        } else if filteredTerms.isEmpty {
                            if terms.isEmpty {
                                EmptyStateView(
                                    title: "No Terms Yet",
                                    message: "Join your chapter’s rush term to get started.",
                                    systemImage: "rectangle.stack.badge.plus",
                                    actionTitle: "Join Term",
                                    action: { showJoin = true }
                                )
                            } else {
                                EmptyStateView(
                                    title: "No Matches",
                                    message: "No terms match your search. Try a different name or code.",
                                    systemImage: "magnifyingglass.circle"
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
            }
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
                    .navigationBarBackButtonHidden(true)
            }
        }
        .tint(SigEpTheme.purple)
    }

    func layoutIcon(mode: TermLayoutMode, systemName: String) -> some View {
        Button {
            layoutMode = mode
        } label: {
            Image(systemName: systemName)
                .imageScale(.medium)
                .frame(width: 28, height: 28)
                .foregroundStyle(layoutMode == mode ? SigEpTheme.purple : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(layoutMode == mode ? SigEpTheme.purple.opacity(0.12) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(layoutMode == mode ? SigEpTheme.purple.opacity(0.6) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTerms) { t in
                    Button {
                        selected = t
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(t.name)
                                    .font(.headline)
                                    .foregroundStyle(SigEpTheme.purple)
                                Text(t.code)
                                    .font(.subheadline)
                                    .foregroundStyle(SigEpTheme.purple.opacity(0.8))
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                if !t.active {
                                    Text("Inactive")
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.red.opacity(0.12))
                                        )
                                        .foregroundStyle(.red)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 1)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
    }

    var gridView: some View {
        ScrollView {
            let cols = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(filteredTerms) { t in
                    Button {
                        selected = t
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(t.name)
                                    .font(.headline)
                                    .foregroundStyle(SigEpTheme.purple)
                                HStack {
                                    Text(t.code)
                                        .font(.subheadline)
                                        .foregroundStyle(SigEpTheme.purple.opacity(0.8))
                                    if !t.active {
                                        Text("Inactive")
                                            .font(.caption2.weight(.semibold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(Color.red.opacity(0.12))
                                            )
                                            .foregroundStyle(.red)
                                    }
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }

    func loadTerms() async {
        loading = true
        defer { loading = false }
        do {
            let all = try await api.myTerms()
            terms = all.sorted { lhs, rhs in
                if lhs.active == rhs.active { return lhs.name < rhs.name }
                return lhs.active && !rhs.active
            }
        } catch {}
    }
}

#Preview("Terms Home") {
    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)
    let ui = AppUIState()

    let view = TermsHomeView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)

    return NavigationStack { view }
}
