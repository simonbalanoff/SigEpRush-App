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
    var body: some View {
        Group {
            if auth.accessToken == nil { LoginView() }
            else { TermsHomeView() }
        }
        .fullScreenCover(isPresented: $ui.showSettings) {
            SettingsView()
        }
    }
}
