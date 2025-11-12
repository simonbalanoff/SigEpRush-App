//
//  PNMDetailView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMDetailView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @StateObject var vm: PNMDetailViewModel
    @State private var showRate = false
    @State private var showPicker = false
    init(initial: PNM) {
        _vm = StateObject(wrappedValue: PNMDetailViewModel(initial: initial))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: vm.pnm.photoURL ?? "")) { i in
                    i.resizable().scaledToFill()
                } placeholder: {
                    ZStack { Color.gray.opacity(0.1); Image(systemName: "person.crop.square").font(.largeTitle).foregroundStyle(.secondary) }
                }
                .frame(height: 220)
                .clipped()
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(vm.pnm.preferredName ?? vm.pnm.firstName) \(vm.pnm.lastName)").font(.title2).bold()
                    if let a = vm.pnm.aggregate, let avg = a.avgScore, let c = a.countRatings {
                        Text("⭐️ \(avg, specifier: "%.1f") • \(c)").foregroundStyle(.secondary)
                    }
                    if let major = vm.pnm.major { Text(major).foregroundStyle(.secondary) }
                    if let gpa = vm.pnm.gpa { Text("GPA \(gpa, specifier: "%.2f")").foregroundStyle(.secondary) }
                }
                HStack {
                    Button("Rate") { showRate = true }.buttonStyle(.borderedProminent)
                    if auth.isAdder {
                        Button(vm.pnm.photoURL == nil ? "Add Photo" : "Replace Photo") { showPicker = true }.buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .sheet(isPresented: $showRate) {
            RatePNMSheet(pnmId: vm.pnm.id) {
                Task {
                    if let updated = try? await api.updatePNM(id: vm.pnm.id, patch: PNMPatch(firstName: nil, lastName: nil, preferredName: nil, classYear: nil, major: nil, gpa: nil, phone: nil, status: nil)) {
                        vm.pnm = updated
                    }
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: .camera) { img in
                Task { await vm.addPhoto(api: api, id: vm.pnm.id, image: img) }
            }
        }
    }
}
