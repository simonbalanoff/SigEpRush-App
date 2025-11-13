//
//  Term.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct TermSummary: Codable, Identifiable, Hashable {
    let termId: String
    let name: String
    let code: String
    let active: Bool
    let joinedAt: String
    var id: String { termId }
}

struct JoinTermResp: Codable { let termId: String; let code: String }

struct CreateTermReq: Encodable {
    let name: String
    let code: String
    let inviteCode: String
    let inviteExpiresAt: String?
    let inviteMaxUses: Int?
}
