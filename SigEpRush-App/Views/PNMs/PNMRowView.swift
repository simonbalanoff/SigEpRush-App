//
//  PNMRowView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMRowView: View {
    let pnm: PNM
    var body: some View {
        HStack(spacing: 12) {
            if let u = pnm.photoURL, let url = URL(string: u) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZstackPlaceholder()
            }
            VStack(alignment: .leading) {
                Text("\(pnm.preferredName ?? pnm.firstName) \(pnm.lastName)").font(.headline)
                if let a = pnm.aggregate?.avgScore {
                    Text(String(format: "Avg %.1f • %d ratings", a, pnm.aggregate?.countRatings ?? 0)).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

private struct ZstackPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.15))
            Image(systemName: "person").foregroundStyle(.secondary)
        }
        .frame(width: 52, height: 52)
    }
}
