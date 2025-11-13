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

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !loading
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SigEpTheme.purple.opacity(1),
                    SigEpTheme.purple.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 10) {
                    Image("SigEpCrest")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)

                    Text("SigEp Rush")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Member Login")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 40)

                VStack(spacing: 18) {
                    CustomPlaceholderField(
                        placeholder: "you@example.com",
                        text: $email,
                        isSecure: false,
                        contentType: .username,
                        keyboard: .emailAddress,
                        iconName: "envelope.fill"
                    )

                    CustomPlaceholderField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true,
                        contentType: .password,
                        keyboard: .default,
                        iconName: "lock.fill"
                    )

                    if let e = err {
                        Text(e)
                            .font(.footnote)
                            .foregroundStyle(Color.red.opacity(0.95))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }

                    Button {
                        Task { await performLogin() }
                    } label: {
                        HStack(spacing: 8) {
                            if loading {
                                ProgressView()
                                    .tint(.black)
                            }
                            Text(loading ? "Signing In..." : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canSubmit ? SigEpTheme.gold : SigEpTheme.gold.opacity(0.5))
                        .foregroundStyle(.black.opacity(canSubmit ? 1 : 0.8))
                        .cornerRadius(14)
                    }
                    .disabled(!canSubmit)

                    Text("Only current SigEp members and rush leaders may sign in.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(22)
                .background(.ultraThinMaterial.opacity(0.85))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.bottom, 32)
        }
        .preferredColorScheme(.dark)
        .onSubmit {
            if canSubmit {
                Task { await performLogin() }
            }
        }
    }

    func performLogin() async {
        loading = true
        err = nil
        defer { loading = false }
        do {
            try await api.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                password: password)
        } catch {
            err = "Invalid email or password"
        }
    }
}

struct CustomPlaceholderField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType
    var iconName: String?

    var body: some View {
        HStack(spacing: 10) {
            if let iconName {
                Image(systemName: iconName)
                    .imageScale(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.55))
                }

                if isSecure {
                    SecureField("", text: $text)
                        .textContentType(contentType)
                        .keyboardType(keyboard)
                        .foregroundColor(.white)
                        .tint(.white)
                } else {
                    TextField("", text: $text)
                        .textContentType(contentType)
                        .keyboardType(keyboard)
                        .foregroundColor(.white)
                        .tint(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(SigEpTheme.surfaceDark)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SigEpTheme.surfaceBorder, lineWidth: 1)
        )
    }
}

#Preview("Login View") {
    let auth = AuthStore()
    let api = APIClient(auth: auth)
    let ui = AppUIState()

    LoginView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
