//
//  RegisterView.swift
//  SigEpRush-App
//
//  Account creation view with password confirmation and invitation code
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var auth: AuthStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var invitationCode = ""
    @State private var err: String?
    @State private var loading = false

    private var canSubmit: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !invitationCode.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        !loading
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword || confirmPassword.isEmpty
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

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 10) {
                        Image("SigEpCrest")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .shadow(color: .black.opacity(0.35), radius: 12, y: 6)

                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Join SigEp Rush")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(.top, 40)

                    VStack(spacing: 18) {
                        CustomPlaceholderField(
                            placeholder: "Invitation Code",
                            text: $invitationCode,
                            isSecure: false,
                            contentType: nil,
                            keyboard: .default,
                            iconName: "key.fill"
                        )
                        
                        CustomPlaceholderField(
                            placeholder: "Full Name",
                            text: $name,
                            isSecure: false,
                            contentType: .name,
                            keyboard: .default,
                            iconName: "person.fill"
                        )
                        
                        CustomPlaceholderField(
                            placeholder: "you@example.com",
                            text: $email,
                            isSecure: false,
                            contentType: .username,
                            keyboard: .emailAddress,
                            iconName: "envelope.fill"
                        )

                        CustomPlaceholderField(
                            placeholder: "Password (min 8 characters)",
                            text: $password,
                            isSecure: true,
                            contentType: .newPassword,
                            keyboard: .default,
                            iconName: "lock.fill"
                        )
                        
                        CustomPlaceholderField(
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: true,
                            contentType: .newPassword,
                            keyboard: .default,
                            iconName: "lock.fill"
                        )
                        
                        if !passwordsMatch && !confirmPassword.isEmpty {
                            Text("Passwords do not match")
                                .font(.footnote)
                                .foregroundStyle(Color.red.opacity(0.95))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }

                        if let e = err {
                            Text(e)
                                .font(.footnote)
                                .foregroundStyle(Color.red.opacity(0.95))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }

                        Button {
                            Task { await performRegister() }
                        } label: {
                            HStack(spacing: 8) {
                                if loading {
                                    ProgressView()
                                        .tint(.black)
                                }
                                Text(loading ? "Creating Account..." : "Create Account")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(canSubmit ? SigEpTheme.gold : SigEpTheme.gold.opacity(0.5))
                            .foregroundStyle(.black.opacity(canSubmit ? 1 : 0.8))
                            .cornerRadius(14)
                        }
                        .disabled(!canSubmit)

                        Button {
                            dismiss()
                        } label: {
                            Text("Already have an account? Sign in")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 4)

                        Text("You need an invitation code from a rush leader to create an account.")
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
                    
                    Spacer(minLength: 32)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .onSubmit {
            if canSubmit {
                Task { await performRegister() }
            }
        }
    }

    func performRegister() async {
        loading = true
        err = nil
        defer { loading = false }
        
        guard password == confirmPassword else {
            err = "Passwords do not match"
            return
        }
        
        guard password.count >= 8 else {
            err = "Password must be at least 8 characters"
            return
        }
        
        do {
            try await api.register(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                invitationCode: invitationCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } catch let error as NSError where error.code == 409 {
            err = error.localizedDescription
        } catch let error as NSError where error.code == 403 {
            err = "Invalid invitation code"
        } catch {
            err = "Registration failed. Please try again."
        }
    }
}

#Preview("Register View") {
    let auth = AuthStore()
    let api = APIClient(auth: auth)
    let ui = AppUIState()

    RegisterView()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
