//
//  Me.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct Me: Codable { let id: String; let name: String; let email: String }
struct LoginReq: Encodable { let email: String; let password: String }
struct LoginResp: Codable { let token: String; let user: Me }
