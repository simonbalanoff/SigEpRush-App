//
//  PNMDetailView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMDetailView: View {
    @EnvironmentObject var api: APIClient
    let pnm: PNM
    @StateObject var vm = PNMDetailViewModel()
    @State private var showRate = false
    private let emojis = ["👍","❤️","🔥","🤝","🤔"]

    var body: some View {
        List {
            header
            Section("Ratings & Comments") {
                ForEach(vm.ratings) { r in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(r.rater?.name ?? "Member").font(.subheadline).bold()
                            Spacer()
                            Text("\(r.score)/10").font(.subheadline)
                        }
                        if let c = r.comment, !c.isEmpty { Text(c) }
                        HStack {
                            ForEach(emojis, id: \.self) { e in
                                let count = r.reactions[e] ?? 0
                                let active = r.myReactions.contains(e)
                                Button {
                                    Task { await vm.toggleReaction(api: api, rating: r, emoji: e) }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(e)
                                        if count > 0 { Text("\(count)").font(.caption2) }
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(active ? Color.blue.opacity(0.15) : Color.gray.opacity(0.12))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("\(pnm.preferredName ?? pnm.firstName) \(pnm.lastName)")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Rate") { showRate = true } } }
        .toolbarSettingsButton()
        .task { await vm.load(api: api, pnmId: pnm.id) }
        .fullScreenCover(isPresented: $showRate) {
            RatePNMSheet(score: vm.myScore, comment: vm.myComment) { s, c in
                vm.myScore = s
                vm.myComment = c
                Task { await vm.submit(api: api, pnmId: pnm.id) }
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlStr = pnm.photoURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.gray.opacity(0.2)
                    }
                }
                .frame(height: 180).clipped().cornerRadius(10)
            }
            if let a = pnm.aggregate?.avgScore {
                Text(String(format: "Average %.1f from %d ratings", a, pnm.aggregate?.countRatings ?? 0)).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
