//
//  JoinTermView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct JoinTermView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIClient

    var onJoined: (JoinTermResp) -> Void

    @State private var code = ""
    @State private var isJoining = false
    @State private var hasError = false
    @State private var toastMessage: String?
    @State private var showToast = false
    @FocusState private var codeFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Image("SigEpCrest")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Join a Rush Term")
                                .font(.title3.weight(.semibold))
                            Text("Enter the code shared by an officer to join their active rush term.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Join code")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "number")
                                    .foregroundStyle(.secondary)
                                TextField("e.g. FALL25-CSU", text: $code)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                    .focused($codeFocused)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasError ? Color.red.opacity(0.7) : SigEpTheme.purple.opacity(0.4), lineWidth: 1)
                            )
                        }

                        Button {
                            join()
                        } label: {
                            HStack {
                                if isJoining {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text("Join Term")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                (code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isJoining)
                                ? Color.gray.opacity(0.3)
                                : SigEpTheme.purple
                            )
                            .foregroundStyle(
                                (code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isJoining)
                                ? Color.gray.opacity(0.7)
                                : Color.white
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(
                                color: (code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isJoining)
                                ? .clear
                                : SigEpTheme.purple.opacity(0.25),
                                radius: 6, y: 3
                            )
                        }
                        .disabled(code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isJoining)
                        .animation(.easeInOut, value: code)
                        .animation(.easeInOut, value: isJoining)

                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()
                }

                if showToast, let message = toastMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .imageScale(.small)
                                .foregroundStyle(.red)
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.7), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.25), radius: 8, y: 4)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 28)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: showToast)
            .navigationTitle("Join Term")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(SigEpTheme.purple)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    codeFocused = true
                }
            }
        }
    }

    private func join() {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        hasError = false
        isJoining = true

        Task {
            do {
                let resp = try await api.joinTerm(code: trimmed)
                await MainActor.run {
                    isJoining = false
                    onJoined(resp)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isJoining = false
                    hasError = true
                    showErrorToast("Invalid or expired code. Check with an officer and try again.")
                }
            }
        }
    }

    private func showErrorToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if showToast {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

#Preview("Join Terms View") {
    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)
    let ui = AppUIState()

    return JoinTermView { _ in }
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)
}
