//
//  AppRoot.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct AppRoot: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var ui: AppUIState
    @EnvironmentObject var api: APIClient

    @State private var checked = false
    @State private var navigateToLastTerm = false
    @State private var lastTerm: TermSummary?

    var body: some View {
        Group {
            if auth.accessToken == nil {
                LoginView()
            } else if !checked {
                LoadingOverlay()
                    .task {
                        await api.loadMe()
                        await loadLastViewedTerm()
                        checked = true
                    }
            } else {
                NavigationStack {
                    TermsHomeView()
                        .navigationDestination(isPresented: $navigateToLastTerm) {
                            if let term = lastTerm {
                                TermWorkspaceView(term: term)
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $ui.showSettings) { SettingsView() }
    }
    
    private func loadLastViewedTerm() async {
        guard let termId = ui.lastViewedTermId else { return }
        
        do {
            let terms = try await api.myTerms()
            if let term = terms.first(where: { $0.termId == termId }) {
                await MainActor.run {
                    lastTerm = term
                    navigateToLastTerm = true
                }
            } else {
                // Term no longer exists or user no longer has access
                ui.clearLastViewedTerm()
            }
        } catch {
            // Failed to load terms, just show home
        }
    }
}

#Preview("App Root") {
    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)
    let ui = AppUIState()

    let view = AppRoot()
        .environmentObject(auth)
        .environmentObject(api)
        .environmentObject(ui)

    return view
}
