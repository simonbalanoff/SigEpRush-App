//
//  PNMDetailViewModel.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import Foundation
import UIKit
import Combine

@MainActor
final class PNMDetailViewModel: ObservableObject {
    @Published var pnm: PNM
    init(initial: PNM) { self.pnm = initial }
    func rate(api: APIClient, id: String, score: Int, comment: String?) async {
        try? await api.ratePNM(id: id, score: score, comment: comment)
    }
    func addPhoto(api: APIClient, id: String, image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        let fixedKey = "pnm/\(id).jpg"
        guard let presign = try? await api.presign(contentType: "image/jpeg", key: fixedKey) else { return }
        try? await S3Uploader.uploadJPEG(data: data, presign: presign)
        if let url = try? await api.attachPhoto(pnmId: id, key: presign.key) {
            var copy = pnm
            copy.photoURL = url
            pnm = copy
        }
    }
}
