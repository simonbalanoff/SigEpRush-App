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
    var systemImage: String? = nil
    var actionTitle: String = "Add"
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(SigEpTheme.purple.opacity(0.9))
                    .padding(.bottom, 4)
            }

            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let action {
                Button(actionTitle) {
                    action()
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(SigEpTheme.purple.opacity(0.12))
                .foregroundStyle(SigEpTheme.purple)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
