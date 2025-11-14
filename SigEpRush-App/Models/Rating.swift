//
//  Rating.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

import Foundation

struct RatingItem: Codable, Identifiable, Hashable {
    let id: String
    var score: Int
    var comment: String?
    var rater: Rater?
    var updatedAt: String
    var reactions: [String:Int]
    var myReactions: [String]

    struct Rater: Codable, Hashable {
        let id: String
        let name: String
        let email: String
    }
}

struct RateUpsertReq: Encodable {
    let score: Int
    let comment: String?
}

struct ReactReq: Encodable {
    let emoji: String
}

struct ReactionsResp: Codable {
    let reactions: [String:Int]
}
