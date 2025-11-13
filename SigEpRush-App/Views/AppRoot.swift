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

    var body: some View {
        Group {
            if auth.accessToken == nil {
                LoginView()
            } else if !checked {
                LoadingOverlay()
                    .task {
                        await api.loadMe()
                        checked = true
                    }
            } else {
                TermsHomeView()
            }
        }
        .fullScreenCover(isPresented: .constant(false)) { EmptyView() }
    }
}
