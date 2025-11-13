//
//  LoginView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var err: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                if let e = err { Text(e).foregroundStyle(.red) }
                Button("Login") {
                    Task {
                        do { try await api.login(email: email, password: password) }
                        catch { err = "Invalid login" }
                    }
                }
            }
            .navigationTitle("Sign In")
        }
    }
}
