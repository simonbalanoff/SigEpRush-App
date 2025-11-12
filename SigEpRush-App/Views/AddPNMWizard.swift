//
//  AddPNMWizard.swift
//  SigEpRush-App
//
//  Created by Simon Balanoff on 11/12/25.
//

import SwiftUI

struct AddPNMWizard: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) var dismiss
    var onCreate: (PNM) -> Void
    @StateObject var vm = PNMWizardViewModel()
    @State private var showPickerOptions = false
    @State private var showLibrary = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack {
                ProgressView(value: Double(vm.step + 1), total: 3).padding(.horizontal)
                content
                HStack {
                    if vm.step > 0 {
                        Button("Back") { vm.step -= 1 }
                    }
                    Spacer()
                    if vm.step < 2 {
                        Button("Next") {
                            if vm.step == 0 && vm.canNextFromInfo { vm.step += 1 }
                            else if vm.step == 1 { vm.step += 1 }
                        }
                        .disabled(vm.step == 0 && !vm.canNextFromInfo)
                    } else {
                        Button(vm.saving ? "Adding…" : "Add") {
                            Task {
                                if let created = await vm.submit(api: api) {
                                    onCreate(created)
                                    dismiss()
                                }
                            }
                        }
                        .disabled(vm.saving || !vm.canNextFromInfo)
                    }
                }
                .padding()
            }
            .navigationTitle("New PNM")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            }
            .sheet(isPresented: $showLibrary) {
                ImagePicker(sourceType: .photoLibrary) { img in
                    vm.image = img
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { img in
                    vm.image = img
                }
            }
            .confirmationDialog("Select Photo", isPresented: $showPickerOptions, actions: {
                Button("Choose from Library") { showLibrary = true }
                Button("Take Photo") { showCamera = true }
                Button("Remove Photo", role: .destructive) { vm.image = nil }
                Button("Cancel", role: .cancel) {}
            })
        }
    }

    @ViewBuilder
    var content: some View {
        switch vm.step {
        case 0: infoView
        case 1: photoView
        default: reviewView
        }
    }

    var infoView: some View {
        Form {
            Section {
                TextField("First name", text: $vm.firstName)
                TextField("Last name", text: $vm.lastName)
                TextField("Preferred name (optional)", text: $vm.preferredName)
            }
            Section {
                TextField("GPA (optional)", text: $vm.gpa).keyboardType(.decimalPad)
                TextField("Major (optional)", text: $vm.major)
                HStack {
                    Text("Class year")
                    Spacer()
                    Text(vm.classYearComputed.map(String.init) ?? "-")
                    Stepper("", value: $vm.gradYearDelta, in: -6...6)
                        .labelsHidden()
                }
            }
            if let e = vm.error { Text(e).foregroundColor(.red) }
        }
    }

    var photoView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08))
                if let img = vm.image {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.square").font(.largeTitle).foregroundStyle(.secondary)
                        Text("Tap to add a photo").foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 300)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture { showPickerOptions = true }
            Spacer()
        }
        .padding()
    }

    var reviewView: some View {
        List {
            Section(header: Text("Info")) {
                HStack { Text("Name"); Spacer(); Text("\(vm.preferredName.isEmpty ? vm.firstName : vm.preferredName) \(vm.lastName)").foregroundStyle(.secondary) }
                if !vm.major.isEmpty { HStack { Text("Major"); Spacer(); Text(vm.major).foregroundStyle(.secondary) } }
                if !vm.gpa.isEmpty { HStack { Text("GPA"); Spacer(); Text(vm.gpa).foregroundStyle(.secondary) } }
                if let y = vm.classYearComputed { HStack { Text("Class Year"); Spacer(); Text(String(y)).foregroundStyle(.secondary) } }
            }
            Section(header: Text("Photo")) {
                if let img = vm.image {
                    Image(uiImage: img).resizable().scaledToFill().frame(height: 180).clipped().cornerRadius(10)
                } else {
                    Text("No photo").foregroundStyle(.secondary)
                }
                Button("Change Photo") { vm.step = 1 }
            }
        }
    }
}
