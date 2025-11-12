//
//  APIClient.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ value: Encodable) { self.encodeFunc = value.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}

struct LoginReq: Encodable { let email: String; let password: String }
struct LoginResp: Decodable { let token: String; let user: Me }
struct PresignReq: Encodable { let contentType: String; let key: String? }
struct PresignResp: Decodable { let key: String; let url: String; let fields: [String:String]; let publicUrl: String }

@MainActor
final class APIClient: ObservableObject {
    let auth: AuthStore
    let session: URLSession = {
        let c = URLSessionConfiguration.ephemeral
        c.waitsForConnectivity = true
        return URLSession(configuration: c)
    }()
    init(auth: AuthStore) { self.auth = auth }
    func request(_ path: String, method: String = "GET", body: Encodable? = nil, authorized: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var url = AppEnv.baseURL
        url.append(path: path)
        var r = URLRequest(url: url)
        r.httpMethod = method
        r.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let b = body { r.httpBody = try JSONEncoder().encode(AnyEncodable(b)) }
        if authorized, let t = auth.accessToken { r.addValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        let (data, resp) = try await session.data(for: r)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return (data, http)
    }
    func login(email: String, password: String) async throws {
        let (d, http) = try await request("auth/login", method: "POST", body: LoginReq(email: email, password: password), authorized: false)
        guard http.statusCode == 200 else { throw URLError(.userAuthenticationRequired) }
        let obj = try JSONDecoder().decode(LoginResp.self, from: d)
        auth.setToken(obj.token, me: obj.user)
    }
    func listPNMs(q: String = "", status: String? = nil, year: Int? = nil, tag: String? = nil) async throws -> [PNM] {
        var comps = URLComponents(url: AppEnv.baseURL.appending(path: "pnms"), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = []
        if !q.isEmpty { items.append(.init(name: "q", value: q)) }
        if let status { items.append(.init(name: "status", value: status)) }
        if let year { items.append(.init(name: "year", value: String(year))) }
        if let tag { items.append(.init(name: "tag", value: tag)) }
        comps.queryItems = items.isEmpty ? nil : items
        var r = URLRequest(url: comps.url!)
        r.httpMethod = "GET"
        r.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let t = auth.accessToken { r.addValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        let (data, resp) = try await session.data(for: r)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PNMListResp.self, from: data).items
    }
    func createPNM(_ p: PNMCreate) async throws -> PNM {
        let (d, http) = try await request("pnms", method: "POST", body: p, authorized: true)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PNM.self, from: d)
    }
    func updatePNM(id: String, patch: PNMPatch) async throws -> PNM {
        let (d, http) = try await request("pnms/\(id)", method: "PATCH", body: patch, authorized: true)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PNM.self, from: d)
    }
    func ratePNM(id: String, score: Int, comment: String?) async throws {
        let payload = RatingPayload(score: score, comment: comment?.isEmpty == true ? nil : comment)
        let (_, http) = try await request("pnms/\(id)/ratings", method: "POST", body: payload, authorized: true)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
    }
    func presign(contentType: String, key: String?) async throws -> PresignResp {
        let (d, http) = try await request("uploads/presign", method: "POST", body: PresignReq(contentType: contentType, key: key), authorized: true)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PresignResp.self, from: d)
    }
    func attachPhoto(pnmId: String, key: String) async throws -> String {
        let (d, http) = try await request("pnms/\(pnmId)/photo/attach", method: "POST", body: ["key": key], authorized: true)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct AttachResp: Decodable { let photoURL: String }
        return try JSONDecoder().decode(AttachResp.self, from: d).photoURL
    }
}
