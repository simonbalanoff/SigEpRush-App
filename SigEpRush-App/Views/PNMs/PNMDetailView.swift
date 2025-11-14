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

    private var displayName: String {
        "\(pnm.preferredName ?? pnm.firstName) \(pnm.lastName)"
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard

                        ratingsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showRate = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.bubble.fill")
                            .imageScale(.medium)
                        Text("Rate")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(SigEpTheme.purple.opacity(0.12))
                    .foregroundStyle(SigEpTheme.purple)
                    .clipShape(Capsule())
                }
            }
        }
        .toolbarSettingsButton()
        .task {
            await vm.load(api: api, pnmId: pnm.id)
        }
        .fullScreenCover(isPresented: $showRate) {
            RatePNMSheet(score: vm.myScore, comment: vm.myComment) { s, c in
                vm.myScore = s
                vm.myComment = c
                Task {
                    await vm.submit(api: api, pnmId: pnm.id)
                    await vm.load(api: api, pnmId: pnm.id)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(SigEpTheme.purple.opacity(0.08))

                if let urlStr = pnm.photoURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                        default:
                            initialsFallback
                        }
                    }
                } else {
                    initialsFallback
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline.weight(.semibold))
                if let major = pnm.major {
                    Text(major)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let year = pnm.classYear {
                    Text("Class of \(year)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var initialsFallback: some View {
        let initials =
            String((pnm.preferredName ?? pnm.firstName).prefix(1)) +
            String(pnm.lastName.prefix(1))

        return ZStack {
            LinearGradient(
                colors: [
                    SigEpTheme.purple.opacity(0.6),
                    SigEpTheme.purple.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(initials.uppercased())
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Overview")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()

                if let a = pnm.aggregate?.avgScore,
                   let count = pnm.aggregate?.countRatings,
                   count > 0 {
                    HStack(spacing: 6) {
                        Text(String(format: "%.1f", a))
                            .font(.headline.weight(.semibold))
                        Text("avg • \(count) ratings")
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(SigEpTheme.purple.opacity(0.08))
                    .foregroundStyle(SigEpTheme.purple)
                    .clipShape(Capsule())
                }
            }

            if let status = pnm.status {
                HStack {
                    Text("Status")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(status.capitalized)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
            }

            if let gpa = pnm.gpa {
                HStack {
                    Text("GPA")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.2f", gpa))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(SigEpTheme.purple)
                }
            }

            if let phone = pnm.phone, !phone.isEmpty {
                HStack {
                    Text("Phone")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(phone)
                        .font(.subheadline.weight(.medium))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }

    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ratings & Comments")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if vm.ratings.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No ratings yet")
                        .font(.subheadline.weight(.medium))
                    Text("Be the first to add your thoughts about this PNM.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.ratings) { r in
                        ratingCard(for: r)
                    }
                }
            }
        }
    }

    private func ratingCard(for r: RatingItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(r.rater?.name ?? "Member")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(r.score)/10")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(SigEpTheme.purple.opacity(0.1))
                    .foregroundStyle(SigEpTheme.purple)
                    .clipShape(Capsule())
            }

            if let c = r.comment, !c.isEmpty {
                Text(c)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                ForEach(emojis, id: \.self) { e in
                    let count = r.reactions[e] ?? 0
                    let active = r.myReactions.contains(e)

                    Button {
                        Task {
                            await vm.toggleReaction(api: api, rating: r, emoji: e)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(e)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2.weight(.semibold))
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            active
                            ? SigEpTheme.purple.opacity(0.18)
                            : Color(.secondarySystemBackground)
                        )
                        .foregroundStyle(
                            active ? SigEpTheme.purple : .secondary
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
    }
}
