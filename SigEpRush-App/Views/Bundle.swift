//
//  Bundle.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 1/27/26.
//

import Foundation

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
