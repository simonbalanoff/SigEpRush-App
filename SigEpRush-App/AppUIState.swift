//
//  AppUIState.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

final class AppUIState: ObservableObject {
    @Published var showSettings = false
    @Published var termsRefreshKey = UUID()
}
