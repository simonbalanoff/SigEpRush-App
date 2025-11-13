//
//  ToolbarSettingsButton.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct ToolbarSettingsButton: ViewModifier {
    @EnvironmentObject var ui: AppUIState
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { ui.showSettings = true } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

extension View {
    func toolbarSettingsButton() -> some View {
        self.modifier(ToolbarSettingsButton())
    }
}
