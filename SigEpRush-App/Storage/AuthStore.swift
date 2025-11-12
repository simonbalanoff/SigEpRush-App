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
    func clear() {
        accessToken = nil
        me = nil
        Keychain.remove("accessToken")
    }
    var isAdder: Bool { me?.role == "Admin" || me?.role == "Adder" }
    var isAdmin: Bool { me?.role == "Admin" }
}
