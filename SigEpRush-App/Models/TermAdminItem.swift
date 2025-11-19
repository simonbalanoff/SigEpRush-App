//
//  TermAdminItem.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct TermAdminItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let code: String
    let inviteCode: String?
    var isActive: Bool
}
