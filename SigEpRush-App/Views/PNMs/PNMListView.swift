//
//  PNMListView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMListView: View {
    @EnvironmentObject var api: APIClient
    let term: TermSummary
    @StateObject var vm = PNMListViewModel()
    @State private var showAdd = false
    @State private var query = ""

    var body: some View {
        List {
            ForEach(vm.items) { p in
                NavigationLink {
                    PNMDetailView(pnm: p)
                } label: {
                    PNMRowView(pnm: p)
                }
            }
        }
        .searchable(text: $query)
        .onChange(of: query) { Task { await vm.load(api: api, termId: term.termId) } }
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus") } } }
        .task { await vm.load(api: api, termId: term.termId) }
        .fullScreenCover(isPresented: $showAdd) {
            AddPNMWizard { _ in
                Task { await vm.load(api: api, termId: term.termId) }
            }
            .environmentObject(api)
            .environment(\.termId, term.termId)
        }
    }
}
