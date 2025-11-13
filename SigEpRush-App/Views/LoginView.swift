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
            SigEpTheme.purple.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image("SigEpCrest")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .shadow(radius: 5)
                    Text("SigEp Rush")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Member Login")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 40)

                VStack(spacing: 20) {
                    CustomPlaceholderField(
                        placeholder: "you@example.com",
                        text: $email,
                        contentType: .username,
                        keyboard: .emailAddress
                    )

                    CustomPlaceholderField(
                        placeholder: "••••••••",
                        text: $password,
                        isSecure: true,
                        contentType: .password
                    )

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

struct CustomPlaceholderField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil
    var keyboard: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.horizontal, 14)
            }

            if isSecure {
                SecureField("", text: $text)
                    .textContentType(contentType)
                    .keyboardType(keyboard)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding(.horizontal, 14)
            } else {
                TextField("", text: $text)
                    .textContentType(contentType)
                    .keyboardType(keyboard)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding(.horizontal, 14)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
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

    return LoginView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
