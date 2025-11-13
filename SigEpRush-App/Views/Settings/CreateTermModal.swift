//
//  CreateTermModal.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct CreateTermModal: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var ui: AppUIState
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var code = ""
    @State private var inviteCode = ""
    @State private var inviteMaxUses: String = ""
    @State private var useExpiry = false
    @State private var expiresAt = Date().addingTimeInterval(60*60*24*30)
    @State private var creating = false
    @State private var error: String?
    @State private var createdCode: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Term Name (e.g. Spring 2026)", text: $name)
                    TextField("Term Code (e.g. sp26)", text: $code).textInputAutocapitalization(.never)
                }
                Section("Join Code") {
                    HStack {
                        TextField("Invite Code", text: $inviteCode).textInputAutocapitalization(.never)
                        Button("Random") { inviteCode = Self.randomCode(8) }
                    }
                    Toggle("Set expiration", isOn: $useExpiry)
                    if useExpiry {
                        DatePicker("Expires", selection: $expiresAt, displayedComponents: [.date, .hourAndMinute])
                    }
                    TextField("Max Uses (optional)", text: $inviteMaxUses).keyboardType(.numberPad)
                }
                if let e = error { Text(e).foregroundColor(.red) }
                if let c = createdCode {
                    Section("Share Code") {
                        Text(c).font(.title2).bold().monospaced()
                        Button("Copy") { UIPasteboard.general.string = c }
                    }
                }
            }
            .navigationTitle("Create Term")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(creating ? "Creating…" : "Create") {
                        Task { await create() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                              code.trimmingCharacters(in: .whitespaces).isEmpty ||
                              inviteCode.trimmingCharacters(in: .whitespaces).isEmpty ||
                              creating)
                }
            }
        }
    }

    func create() async {
        creating = true
        defer { creating = false }
        do {
            let iso: String? = useExpiry ? ISO8601DateFormatter().string(from: expiresAt) : nil
            let maxUses: Int? = Int(inviteMaxUses)
            let payload = CreateTermReq(name: name, code: code.lowercased(), inviteCode: inviteCode, inviteExpiresAt: iso, inviteMaxUses: maxUses)
            _ = try await api.createTerm(payload)
            createdCode = inviteCode
        } catch {
            self.error = "Failed to create term"
        }
    }

    static func randomCode(_ n: Int) -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<n).map { _ in chars.randomElement()! })
    }
}
