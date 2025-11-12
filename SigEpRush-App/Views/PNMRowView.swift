//
//  PNMRowView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMRowView: View {
    let p: PNM
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: p.photoURL ?? "")) { i in
                i.resizable().scaledToFill()
            } placeholder: {
                ZStack { Color.gray.opacity(0.15); Image(systemName: "person.crop.circle").font(.title2).foregroundStyle(.secondary) }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("\(p.preferredName ?? p.firstName) \(p.lastName)").font(.headline)
                if let a = p.aggregate, let avg = a.avgScore, let c = a.countRatings {
                    Text("⭐️ \(avg, specifier: "%.1f") • \(c)").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(p.status.capitalized).font(.caption).padding(.horizontal,8).padding(.vertical,4).background(Color.secondary.opacity(0.15)).clipShape(Capsule())
        }
    }
}
