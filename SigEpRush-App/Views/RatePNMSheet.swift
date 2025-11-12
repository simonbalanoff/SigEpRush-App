//
//  RatePNMSheet.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct RatePNMSheet: View {
    @EnvironmentObject var api: APIClient
    let pnmId: String
    var onDone: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var score = 5.0
    @State private var comment = ""
    @State private var loading = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        Slider(value: $score, in: 0...10, step: 1)
                        Text("Score \(Int(score))/10")
                    }
                    TextField("Comment", text: $comment, axis: .vertical)
                }
            }
            .navigationTitle("Rate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loading ? "Saving…" : "Save") {
                        Task {
                            loading = true
                            defer { loading = false }
                            try? await api.ratePNM(id: pnmId, score: Int(score), comment: comment)
                            onDone()
                            dismiss()
                        }
                    }.disabled(loading)
                }
            }
        }
    }
}
