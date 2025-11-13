//
//  LoadingOverlay.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
