//
//  CreatePNMSheet.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct CreatePNMSheet: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) var dismiss
    var onCreate: () async -> Void
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var preferredName = ""
    @State private var classYear = ""
    @State private var major = ""
    @State private var gpa = ""
    @State private var status = "new"
    @State private var saving = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                    TextField("Preferred name", text: $preferredName)
                    TextField("Class year", text: $classYear).keyboardType(.numberPad)
                    TextField("Major", text: $major)
                    TextField("GPA", text: $gpa).keyboardType(.decimalPad)
                    Picker("Status", selection: $status) {
                        Text("New").tag("new")
                        Text("Invited").tag("invited")
                        Text("Bid").tag("bid")
                        Text("Declined").tag("declined")
                    }
                }
            }
            .navigationTitle("Add PNM")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saving ? "Saving…" : "Save") {
                        Task {
                            saving = true
                            defer { saving = false }
                            let payload = PNMCreate(
                                firstName: firstName,
                                lastName: lastName,
                                preferredName: preferredName.isEmpty ? nil : preferredName,
                                classYear: Int(classYear),
                                major: major.isEmpty ? nil : major,
                                gpa: Double(gpa),
                                phone: nil,
                                status: status
                            )
                            _ = try? await api.createPNM(payload)
                            await onCreate()
                            dismiss()
                        }
                    }.disabled(firstName.isEmpty || lastName.isEmpty || saving)
                }
            }
        }
    }
}
