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
    @State private var err: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter join code", text: $code).textInputAutocapitalization(.never).autocorrectionDisabled()
                }
                if let e = err { Text(e).foregroundStyle(.red) }
            }
            .navigationTitle("Join Term")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        Task {
                            do {
                                let r = try await api.joinTerm(code: code)
                                onJoined(r)
                                dismiss()
                            } catch { err = "Invalid or expired code" }
                        }
                    }.disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
