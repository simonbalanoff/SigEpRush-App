//
//  RatePNMSheet.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct RatePNMSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var score: Int
    @State var comment: String
    var onSubmit: (Int,String)->Void
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Score")
                    Spacer()
                    Stepper("\(score)", value: $score, in: 0...10)
                }
                TextField("Comment (optional)", text: $comment, axis: .vertical)
            }
            .navigationTitle("Your Rating")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSubmit(score, comment)
                        dismiss()
                    }
                }
            }
        }
    }
}
