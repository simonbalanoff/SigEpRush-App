//
//  PNMListView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

enum PNMLayoutMode: String, CaseIterable, Identifiable {
    case list
    case grid
    var id: Self { self }
}

struct PNMListView: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) private var dismiss

    let term: TermSummary

    @StateObject var vm: PNMListViewModel

    init(term: TermSummary, previewVM: PNMListViewModel? = nil) {
        self.term = term
        _vm = StateObject(wrappedValue: previewVM ?? PNMListViewModel())
    }
    
    @State private var showAdd = false
    @State private var query = ""
    @State private var layoutMode: PNMLayoutMode = .list

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                searchBar
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await vm.load(api: api, termId: term.termId)
        }
        .onChange(of: query) {
            Task { await vm.load(api: api, termId: term.termId) }
        }
        .fullScreenCover(isPresented: $showAdd) {
            AddPNMWizard { _ in
                Task { await vm.load(api: api, termId: term.termId) }
            }
            .environmentObject(api)
            .environment(\.termId, term.termId)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
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
                Text(term.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                layoutIcon(mode: .list, systemName: "list.bullet")
                layoutIcon(mode: .grid, systemName: "square.grid.2x2")

                Button {
                    showAdd = true
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
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search PNMs", text: $query)
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

    private var content: some View {
        Group {
            switch layoutMode {
            case .list:
                listView
            case .grid:
                gridView
            }
        }
    }

    private var listView: some View {
        List {
            ForEach(vm.items) { p in
                NavigationLink {
                    PNMDetailView(pnm: p)
                } label: {
                    PNMRowView(pnm: p)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var gridView: some View {
        ScrollView {
            let cols = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: cols, spacing: 16) {
                ForEach(vm.items) { p in
                    NavigationLink {
                        PNMDetailView(pnm: p)
                    } label: {
                        VStack(spacing: 8) {
                            avatarSquare(for: p)

                            Text(p.preferredName ?? "\(p.firstName) \(p.lastName)")
                                .font(.headline)
                                .foregroundStyle(SigEpTheme.purple)
                                .multilineTextAlignment(.center)

                            if let major = p.major {
                                Text(major)
                                    .font(.caption)
                                    .foregroundStyle(SigEpTheme.purple)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private func layoutIcon(mode: PNMLayoutMode, systemName: String) -> some View {
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
    
    private func avatarSquare(for p: PNM) -> some View {
        let fallbackInitials = String((p.preferredName ?? p.firstName).prefix(1)) +
                               String(p.lastName.prefix(1))

        return Group {
            if let urlString = p.photoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(SigEpTheme.purple.opacity(0.1))
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(SigEpTheme.purple.opacity(0.1))
                            Text(fallbackInitials)
                                .font(.title.weight(.semibold))
                                .foregroundStyle(SigEpTheme.purple)
                        }
                    @unknown default:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(SigEpTheme.purple.opacity(0.1))
                            Text(fallbackInitials)
                                .font(.title.weight(.semibold))
                                .foregroundStyle(SigEpTheme.purple)
                        }
                    }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(SigEpTheme.purple.opacity(0.1))
                    Text(fallbackInitials)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(SigEpTheme.purple)
                }
                .frame(height: 120)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let term = TermSummary(
        termId: "demo-term",
        name: "Fall 2025",
        code: "F25",
        active: true,
        joinedAt: ""
    )

    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)
    let previewVM = PNMListViewModel.preview

    return NavigationStack {
        PNMListView(term: term, previewVM: previewVM)
            .environmentObject(api)
            .environmentObject(auth)
            .environment(\.termId, term.termId)
    }
}
