//
//  PNMRowView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct PNMRowView: View {
    let pnm: PNM

    var initials: String {
        let first = (pnm.preferredName ?? pnm.firstName).first ?? "?"
        let last = pnm.lastName.first ?? "?"
        return "\(first)\(last)"
    }

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text("\(pnm.preferredName ?? pnm.firstName) \(pnm.lastName)")
                    .font(.headline)
                    .foregroundStyle(SigEpTheme.purple)

                if let a = pnm.aggregate?.avgScore {
                    Text(String(format: "Avg %.1f • %d ratings", a, pnm.aggregate?.countRatings ?? 0))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private var avatar: some View {
        Group {
            if let u = pnm.photoURL, let url = URL(string: u) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(SigEpTheme.purple.opacity(0.12))

            Text(initials)
                .font(.headline.weight(.semibold))
                .foregroundStyle(SigEpTheme.purple)
        }
    }
}
