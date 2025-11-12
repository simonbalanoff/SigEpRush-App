//
//  PNMListView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMListView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @StateObject var vm = PNMListViewModel()
    @State private var showAdd = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.items) { p in
                    NavigationLink(value: p) {
                        PNMRowView(p: p)
                    }
                }
            }
            .navigationDestination(for: PNM.self) { p in
                PNMDetailView(initial: p)
            }
            .searchable(text: $vm.q)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let n = auth.me?.name { Text(n).font(.subheadline).foregroundStyle(.secondary) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if auth.isAdder { Button { showAdd = true } label: { Image(systemName: "plus") } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) { Image(systemName: "gearshape") }
                }
            }
            .navigationTitle("PNMs")
            .task { await vm.load(api: api) }
            .refreshable { await vm.load(api: api) }
            .onChange(of: vm.q) { Task { await vm.load(api: api) } }
            .sheet(isPresented: $showAdd) { CreatePNMSheet(onCreate: { await vm.load(api: api) }) }
        }
    }
}
