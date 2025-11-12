//
//  PNMWizardViewModel.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PNMWizardViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var preferredName = ""
    @Published var major = ""
    @Published var gpa = ""
    @Published var image: UIImage?
    @Published var step = 0
    @Published var saving = false
    @Published var error: String?
    @Published private(set) var baseGradYear: Int = 0
    @Published var gradYearDelta: Int = 0

    init() { baseGradYear = Self.computeBaseGradYear() }

    var classYearComputed: Int? { baseGradYear + gradYearDelta }

    var canNextFromInfo: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static func computeBaseGradYear() -> Int {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        let month = cal.component(.month, from: Date())
        return year + ((1...4).contains(month) ? 3 : 4)
    }

    func submit(termId: String, api: APIClient) async -> PNM? {
        saving = true
        defer { saving = false }
        let payload = PNMCreate(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            preferredName: preferredName.isEmpty ? nil : preferredName,
            classYear: classYearComputed,
            major: major.isEmpty ? nil : major,
            gpa: Double(gpa),
            phone: nil,
            status: "new"
        )
        do {
            var created = try await api.createPNM(termId: termId, payload: payload)
            if let img = image, let data = img.jpegData(compressionQuality: 0.9) {
                let key = "pnm/\(created.termId)/\(created.id).jpg"
                let presign = try await api.presign(contentType: "image/jpeg", key: key)
                try await Uploader.uploadJPEG(data: data, presign: presign)
                let url = try await api.attachPhoto(pnmId: created.id, key: presign.key)
                created.photoURL = url
            }
            return created
        } catch {
            self.error = "Failed to add PNM"
            return nil
        }
    }
}
