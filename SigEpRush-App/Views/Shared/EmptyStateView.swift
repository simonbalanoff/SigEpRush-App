//
//  EmptyStateView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var actionTitle: String = "Add"
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.title2).bold()
            Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
            if let action { Button(actionTitle, action: action) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
