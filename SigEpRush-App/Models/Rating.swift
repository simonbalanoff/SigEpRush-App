//
//  Rating.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct RatingItem: Codable, Identifiable, Hashable {
    let id: String
    let score: Int
    let comment: String?
    let rater: Rater?
    let updatedAt: String
    let reactions: [String:Int]
    let myReactions: [String]
    struct Rater: Codable, Hashable {
        let id: String
        let name: String
        let email: String
    }
}

struct RateUpsertReq: Encodable { let score: Int; let comment: String? }
struct ReactReq: Encodable { let emoji: String }
struct ReactionsResp: Codable { let reactions: [String:Int] }
