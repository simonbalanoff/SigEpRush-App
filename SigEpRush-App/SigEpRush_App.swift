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
    var body: some Scene {
        WindowGroup {
            AppRoot()
                .enviromentObject(auth)
                .enviromentObject(APIClient(auth: auth))
        }
    }
}
