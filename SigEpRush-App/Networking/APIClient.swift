//
//  APIClient.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

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
        if let b = body {
            let enc = JSONEncoder()
            r.httpBody = try enc.encode(AnyEncodable(b))
        }
        if authorized, let t = auth.accessToken { r.addValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
        let (data, resp) = try await session.data(for: r)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return (data, http)
    }

    func login(email: String, password: String) async throws {
        let (d, http) = try await request("auth/login", method: "POST", body: LoginReq(email: email, password: password), authorized: false)
        guard http.statusCode == 200 else { throw URLError(.userAuthenticationRequired) }
        let o = try JSONDecoder().decode(LoginResp.self, from: d)
        auth.setTokens(access: o.token, refresh: "")
        auth.me = o.user
    }
    
    func loadMe() async {
        do {
            let (d, http) = try await request("auth/me", authorized: true)
            guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
            let me = try JSONDecoder().decode(Me.self, from: d)
            auth.me = me
        } catch {
            auth.clear()
        }
    }

    func myTerms() async throws -> [TermSummary] {
        let (d, http) = try await request("terms/mine")
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct Resp: Codable { let items: [TermSummary] }
        return try JSONDecoder().decode(Resp.self, from: d).items
    }

    func createTerm(_ payload: CreateTermReq) async throws -> String {
        let (d, http) = try await request("terms", method: "POST", body: payload)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct R: Codable { let id: String }
        return try JSONDecoder().decode(R.self, from: d).id
    }

    func joinTerm(code: String) async throws -> JoinTermResp {
        let (d, http) = try await request("terms/join", method: "POST", body: ["code": code])
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(JoinTermResp.self, from: d)
    }
    
    func adminTerms() async throws -> [TermAdminItem] {
        let (d, http) = try await request("terms/admin")
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct Resp: Codable { let items: [TermAdminItem] }
        return try JSONDecoder().decode(Resp.self, from: d).items
    }

    func setTermActive(termId: String, active: Bool) async throws {
        let (_, http) = try await request("terms/\(termId)", method: "PATCH", body: ["isActive": active])
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
    }

    func pnms(termId: String, q: String = "") async throws -> [PNM] {
        var path = "terms/\(termId)/pnms"
        if !q.isEmpty {
            path += "?q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        let (d, http) = try await request(path)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct Resp: Codable { let items: [PNM] }
        let resp = try JSONDecoder().decode(Resp.self, from: d)
        return resp.items
    }

    func createPNM(termId: String, payload: PNMCreate) async throws -> PNM {
        let (d, http) = try await request("terms/\(termId)/pnms", method: "POST", body: payload)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PNM.self, from: d)
    }

    func presign(contentType: String, key: String) async throws -> PresignResp {
        let (d, http) = try await request("uploads/presign", method: "POST", body: ["contentType": contentType, "key": key])
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PresignResp.self, from: d)
    }

    func attachPhoto(pnmId: String, key: String) async throws -> String {
        let (d, http) = try await request("pnms/\(pnmId)/photo/attach", method: "POST", body: ["key": key])
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct R: Codable { let photoURL: String }
        return try JSONDecoder().decode(R.self, from: d).photoURL
    }

    func ratings(pnmId: String) async throws -> [RatingItem] {
        let (d, http) = try await request("pnms/\(pnmId)/ratings")
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        struct Resp: Codable { let items: [RatingItem] }
        return try JSONDecoder().decode(Resp.self, from: d).items
    }

    func upsertRating(pnmId: String, score: Int, comment: String?) async throws {
        let req = RateUpsertReq(score: score, comment: comment)
        let (_, http) = try await request("pnms/\(pnmId)/ratings", method: "POST", body: req)
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
    }

    func deleteMyRating(pnmId: String) async throws {
        let (_, http) = try await request("pnms/\(pnmId)/ratings/mine", method: "DELETE")
        guard http.statusCode == 204 else { throw URLError(.badServerResponse) }
    }

    func react(ratingId: String, emoji: String) async throws -> [String:Int] {
        let (d, http) = try await request("ratings/\(ratingId)/reactions", method: "POST", body: ReactReq(emoji: emoji))
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(ReactionsResp.self, from: d).reactions
    }

    func unreact(ratingId: String, emoji: String) async throws -> [String:Int] {
        let (d, http) = try await request("ratings/\(ratingId)/reactions", method: "DELETE", body: ReactReq(emoji: emoji))
        guard http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(ReactionsResp.self, from: d).reactions
    }
}

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ value: Encodable) { self.encodeFunc = value.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
