//
//  Me.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct Me: Codable { let id: String; let name: String; let role: String; let email: String }
struct LoginReq: Encodable { let email: String; let password: String }
struct RegisterReq: Codable { let email: String; let password: String; let name: String; let invitationCode: String }
struct LoginResp: Codable { let token: String; let user: Me }

struct UserListItem: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: String
    let isActive: Bool
    let createdAt: String?
}

struct UpdateUserRoleReq: Codable {
    let role: String
}
