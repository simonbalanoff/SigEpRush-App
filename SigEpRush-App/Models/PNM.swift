//
//  PNM.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct Aggregate: Codable {
    let avgScore: Double?
    let distScore: [String:Int]?
    let countRatings: Int?
    let lastRatedAt: String?
}

struct PNM: Codable, Identifiable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var preferredName: String?
    var classYear: Int?
    var major: String?
    var gpa: Double?
    var phone: String?
    var photoURL: String?
    var status: String
    var aggregate: Aggregate?
}

struct PNMListResp: Codable {
    let items: [PNM]
}

struct PNMCreate: Encodable {
    let firstName: String
    let lastName: String
    let preferredName: String?
    let classYear: Int?
    let major: String?
    let gpa: Double?
    let phone: String?
    let status: String?
}

struct PNMPatch: Encodable {
    let firstName: String?
    let lastName: String?
    let preferredName: String?
    let classYear: Int?
    let major: String?
    let gpa: String?
    let phone: String?
    let status: String?
}
