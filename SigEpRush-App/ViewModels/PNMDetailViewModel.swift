//
//  PNMDetailViewModel.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

@MainActor
final class PNMDetailViewModel: ObservableObject {
    @Published var ratings: [RatingItem] = []
    @Published var myScore: Int = 5
    @Published var myComment: String = ""
    @Published var sending = false

    func load(api: APIClient, pnmId: String) async {
        do { ratings = try await api.ratings(pnmId: pnmId) } catch {}
    }

    func submit(api: APIClient, pnmId: String) async {
        sending = true
        defer { sending = false }
        do {
            try await api.upsertRating(pnmId: pnmId, score: myScore, comment: myComment.isEmpty ? nil : myComment)
            try await Task.sleep(nanoseconds: 150_000_000)
            ratings = try await api.ratings(pnmId: pnmId)
        } catch {}
    }

    func toggleReaction(api: APIClient, rating: RatingItem, emoji: String) async {
        do {
            let mine = Set(rating.myReactions)
            let updated = try await (mine.contains(emoji) ? api.unreact(ratingId: rating.id, emoji: emoji) : api.react(ratingId: rating.id, emoji: emoji))
            if let i = ratings.firstIndex(where: { $0.id == rating.id }) {
                var r = ratings[i]
                var mr = Set(r.myReactions)
                if mr.contains(emoji) { mr.remove(emoji) } else { mr.insert(emoji) }
                r.myReactions = Array(mr)
                r.reactions = updated
                ratings[i] = r
            }
        } catch {}
    }
}
