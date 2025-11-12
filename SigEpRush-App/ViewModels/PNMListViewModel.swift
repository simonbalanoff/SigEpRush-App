//
//  PNMListViewModel.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import Combine

@MainActor
final class PNMListViewModel: ObservableObject {
    @Published var items: [PNM] = []
    @Published var q = ""
    @Published var loading = false

    func load(api: APIClient, termId: String) async {
        loading = true
        defer { loading = false }
        do { items = try await api.pnms(termId: termId, q: q) } catch {}
    }
}
