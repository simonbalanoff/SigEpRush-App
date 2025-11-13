//
//  SigEpRush_AppApp.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

@main
struct SigEpRush_AppApp: App {
    @StateObject var auth = AuthStore()
    @StateObject var ui = AppUIState()
    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environmentObject(auth)
                .environmentObject(APIClient(auth: auth))
                .environmentObject(ui)
        }
    }
}
