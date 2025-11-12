//
//  LoginView.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var api: APIClient
    @StateObject var vm = AuthViewModel()
    var body: some View {
        VStack(spacing: 16) {
            Text("SigEp Rush").font(.largeTitle).bold()
            TextField("Email", text: $vm.email).textInputAutocapitalization(.never).keyboardType(.emailAddress).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $vm.password).textFieldStyle(.roundedBorder)
            if let e = vm.err { Text(e).foregroundColor(.red) }
            Button { Task { await vm.login(api: api) } } label: {
                Text(vm.loading ? "Signing in…" : "Sign in").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.loading || vm.email.isEmpty || vm.password.isEmpty)
        }
        .padding()
    }
}
