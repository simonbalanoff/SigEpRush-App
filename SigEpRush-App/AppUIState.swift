//
//  AppUIState.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

@MainActor
final class AppUIState: ObservableObject {
    @Published var showSettings = false
    @Published var termsRefreshKey = UUID()
    @Published var lastViewedTermId: String? {
        didSet {
            if let termId = lastViewedTermId {
                UserDefaults.standard.set(termId, forKey: "lastViewedTermId")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastViewedTermId")
            }
        }
    }
    
    init() {
        self.lastViewedTermId = UserDefaults.standard.string(forKey: "lastViewedTermId")
    }
    
    func clearLastViewedTerm() {
        lastViewedTermId = nil
    }
}
