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
        do {
            ratings = try await api.ratings(pnmId: pnmId)
        } catch {}
    }

    func submit(api: APIClient, pnmId: String) async {
        sending = true
        defer { sending = false }
        do {
            try await api.upsertRating(
                pnmId: pnmId,
                score: myScore,
                comment: myComment.isEmpty ? nil : myComment
            )
            ratings = try await api.ratings(pnmId: pnmId)
        } catch {}
    }

    func toggleReaction(api: APIClient, rating: RatingItem, emoji: String) async {
        guard let index = ratings.firstIndex(where: { $0.id == rating.id }) else { return }

        var updatedRating = ratings[index]
        let alreadyReacted = updatedRating.myReactions.contains(emoji)

        do {
            let newReactions: [String:Int]
            if alreadyReacted {
                newReactions = try await api.unreact(ratingId: updatedRating.id, emoji: emoji)
                updatedRating.myReactions.removeAll(where: { $0 == emoji })
            } else {
                newReactions = try await api.react(ratingId: updatedRating.id, emoji: emoji)
                updatedRating.myReactions.append(emoji)
            }
            updatedRating.reactions = newReactions
            ratings[index] = updatedRating
        } catch {}
    }
}
