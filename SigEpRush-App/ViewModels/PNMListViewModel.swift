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
    
    static var preview: PNMListViewModel {
        let vm = PNMListViewModel()
        vm.items = [
            PNM(
                id: "1",
                termId: "demo-term",
                firstName: "John",
                lastName: "Adams",
                preferredName: "Johnny",
                classYear: 2028,
                major: "Computer Science",
                gpa: 3.8,
                phone: "555-111-2222",
                photoURL: nil,
                status: "Interested",
                aggregate: nil
            ),
            PNM(
                id: "2",
                termId: "demo-term",
                firstName: "Daniel",
                lastName: "Perez",
                preferredName: nil,
                classYear: 2027,
                major: "Business",
                gpa: 3.6,
                phone: "555-222-3333",
                photoURL: nil,
                status: "Hot",
                aggregate: nil
            ),
            PNM(
                id: "3",
                termId: "demo-term",
                firstName: "Liam",
                lastName: "O’Connor",
                preferredName: nil,
                classYear: 2026,
                major: "Mechanical Eng",
                gpa: 3.4,
                phone: "555-333-4444",
                photoURL: nil,
                status: "Maybe",
                aggregate: nil
            )
        ]
        return vm
    }
}
