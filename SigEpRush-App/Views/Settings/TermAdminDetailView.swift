//
//  TermAdminDetailView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/18/25.
//

import SwiftUI

struct TermAdminDetailView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var ui: AppUIState
    @Environment(\.dismiss) var dismiss

    let term: TermAdminItem
    @State private var workingTerm: TermAdminItem
    @State private var isUpdatingActive = false
    @State private var error: String?

    init(term: TermAdminItem) {
        self.term = term
        _workingTerm = State(initialValue: term)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header

                if let e = error {
                    Text(e)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        termInfoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .tint(SigEpTheme.purple)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
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

            Image("SigEpCrest")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("SigEp Rush")
                    .font(.headline.weight(.semibold))
                Text("Term Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var termInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Term Details")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(workingTerm.name)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)

                Divider()
                
                HStack {
                    Text("Code")
                    Spacer()
                    Text(workingTerm.code)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 12)

                Divider()
                
                HStack {
                    Text("Invite Code")
                    Spacer()
                    Text(workingTerm.inviteCode ?? "—")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 12)

                Divider()

                HStack {
                    Text("Active")
                    Spacer()
                    if isUpdatingActive {
                        ProgressView()
                    } else {
                        Toggle("", isOn: Binding(
                            get: { workingTerm.isActive },
                            set: { newVal in
                                updateActive(newVal)
                            }
                        ))
                        .labelsHidden()
                    }
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        }
    }

    private func updateActive(_ newVal: Bool) {
        let old = workingTerm.isActive
        workingTerm.isActive = newVal
        isUpdatingActive = true
        error = nil

        Task {
            do {
                try await api.setTermActive(termId: workingTerm.id, active: newVal)
                await MainActor.run {
                    ui.termsRefreshKey = UUID()
                    isUpdatingActive = false
                }
            } catch {
                await MainActor.run {
                    workingTerm.isActive = old
                    isUpdatingActive = false
                    self.error = "Failed to update active state"
                }
            }
        }
    }
}
