//
//  PNM.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation

struct Aggregate: Codable, Hashable {
    let avgScore: Double?
    let distScore: [String:Int]?
    let countRatings: Int?
    let lastRatedAt: String?
}

struct PNM: Codable, Identifiable, Hashable {
    let id: String
    let termId: String
    var firstName: String
    var lastName: String
    var preferredName: String?
    var classYear: Int?
    var major: String?
    var gpa: Double?
    var phone: String?
    var photoURL: String?
    var status: String?
    var aggregate: Aggregate?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case termId
        case firstName
        case lastName
        case preferredName
        case classYear
        case major
        case gpa
        case phone
        case photoURL
        case status
        case aggregate
    }
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
