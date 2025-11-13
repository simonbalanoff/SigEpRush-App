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
    @State private var loading = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SigEpTheme.purple.opacity(0.95),
                    SigEpTheme.red.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image("SigEpCrest")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 96)
                        .shadow(radius: 12)
                    Text("SigEp Rush")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Member Login")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 40)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Email")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        TextField("you@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .textContentType(.username)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(SigEpTheme.surfaceDark)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .cornerRadius(12)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(SigEpTheme.surfaceBorder, lineWidth: 1)
                            )
                    }
                    .accentColor(.white)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Password")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        SecureField("••••••••", text: $password)
                            .textContentType(.password)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(SigEpTheme.surfaceDark)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(SigEpTheme.surfaceBorder, lineWidth: 1)
                            )
                    }

                    if let e = err {
                        Text(e)
                            .font(.footnote)
                            .foregroundStyle(Color.red.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await performLogin() }
                    } label: {
                        HStack {
                            if loading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(SigEpTheme.gold)
                        .foregroundStyle(.black)
                        .cornerRadius(14)
                        .shadow(color: SigEpTheme.gold.opacity(0.4), radius: 10, y: 4)
                    }
                    .disabled(loading || email.isEmpty || password.isEmpty)
                    .opacity(loading || email.isEmpty || password.isEmpty ? 0.7 : 1)
                }
                .padding(22)
                .background(.ultraThinMaterial.opacity(0.7))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.bottom, 32)
        }
        .preferredColorScheme(.dark)
    }

    func performLogin() async {
        loading = true
        err = nil
        defer { loading = false }
        do {
            try await api.login(email: email, password: password)
        } catch {
            err = "Invalid email or password"
        }
    }
}

#Preview("Login View") {
    let auth = AuthStore()
    let api = APIClient(auth: auth)
    let ui = AppUIState()

    return LoginView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
