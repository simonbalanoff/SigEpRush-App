//
//  AuthStore.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

@MainActor
final class AuthStore: ObservableObject {
    @Published var accessToken: String? = Keychain.get("accessToken")
    @Published var me: Me?

    func setToken(_ token: String, me: Me) {
        accessToken = token
        self.me = me
        Keychain.set(token, key: "accessToken")
    }

    func setTokens(access: String, refresh: String) {
        accessToken = access
        Keychain.set(access, key: "accessToken")
    }

    func clear() {
        accessToken = nil
        me = nil
        Keychain.remove("accessToken")
    }
}
