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

    var onSubmit: (Int, String) -> Void

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        scoreCard
                        commentCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }

                footerButtons
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(SigEpTheme.purple)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Rate PNM")
                    .font(.headline.weight(.semibold))
                Text("Share your score and feedback")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Score")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(score)/10")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SigEpTheme.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(SigEpTheme.purple.opacity(0.08))
                    .clipShape(Capsule())
            }

            Slider(
                value: Binding(
                    get: { Double(score) },
                    set: { score = Int($0) }
                ),
                in: 0...10,
                step: 1
            )
            .tint(SigEpTheme.purple)

            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("10")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }

    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Comment")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .topLeading) {
                if comment.isEmpty {
                    Text("Share any context that helps other members.")
                        .foregroundStyle(.secondary.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }

                TextEditor(text: $comment)
                    .frame(minHeight: 100, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .padding(8)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(SigEpTheme.purple.opacity(0.15), lineWidth: 1)
            )
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }

    private var footerButtons: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: {
                onSubmit(score, comment)
                dismiss()
            }) {
                HStack {
                    Spacer()
                    Text("Save Rating")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .background(SigEpTheme.purple)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 26)
    }
}

#Preview("Rate PNM Sheet") {
    RatePNMSheet(score: 7, comment: "") { _, _ in }
        .environmentObject(APIClient(auth: AuthStore()))
}
