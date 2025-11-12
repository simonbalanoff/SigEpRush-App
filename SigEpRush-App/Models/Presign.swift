//
//  Presign.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct PresignResp: Codable {
    let key: String
    let url: String
    let fields: [String:String]
    let publicUrl: String
}
