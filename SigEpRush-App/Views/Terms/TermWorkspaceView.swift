//
//  TermWorkspaceView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

private struct TermIdKey: EnvironmentKey { static let defaultValue: String = "" }

extension EnvironmentValues { var termId: String { get { self[TermIdKey.self] } set { self[TermIdKey.self] = newValue } } }

struct TermWorkspaceView: View {
    @EnvironmentObject var ui: AppUIState
    let term: TermSummary

    var body: some View {
        PNMListView(term: term)
            .onAppear {
                ui.lastViewedTermId = term.termId
            }
            .environment(\.termId, term.termId)
            .navigationBarTitleDisplayMode(.inline)
    }
}
