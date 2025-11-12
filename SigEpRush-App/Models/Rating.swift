//
//  Rating.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct RatingPayload: Codable {
    let score: Int
    let comment: String?
}
