//
//  AuthViewModel.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var loading = false
    @Published var err: String?
    func login(api: APIClient) async {
        loading = true
        defer { loading = false }
        do { try await api.login(email: email, password: password) } catch { err = "Login failed" }
    }
}
