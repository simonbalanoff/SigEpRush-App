//
//  ImagePicker.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    enum Source { case camera, photoLibrary }
    let sourceType: Source
    let onPick: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .camera:
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.delegate = context.coordinator
            return vc
        case .photoLibrary:
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
        let onPick: (UIImage) -> Void
        init(onPick: @escaping (UIImage) -> Void) { self.onPick = onPick }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage { onPick(img) }
            picker.dismiss(animated: true)
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let item = results.first?.itemProvider, item.canLoadObject(ofClass: UIImage.self) else { picker.dismiss(animated: true); return }
            item.loadObject(ofClass: UIImage.self) { obj, _ in
                if let img = obj as? UIImage { DispatchQueue.main.async { self.onPick(img) } }
            }
            picker.dismiss(animated: true)
        }
    }
}
