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
    @Environment(\.termId) var termId

    var onCreate: (PNM) -> Void

    @StateObject var vm = PNMWizardViewModel()
    @State private var showPickerOptions = false
    @State private var showLibrary = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView(value: Double(vm.step + 1), total: 3)
                        .tint(SigEpTheme.purple)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 20) {
                            content
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }

                    HStack {
                        Button(action: {
                            if vm.step == 0 {
                                dismiss()
                            } else {
                                vm.step -= 1
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text(vm.step == 0 ? "Cancel" : "Back")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(height: 44)
                            .contentShape(Rectangle())
                        }
                        .frame(maxWidth: 160)
                        .background(SigEpTheme.purple)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Spacer()

                        if vm.step < 2 {
                            Button(action: {
                                if vm.step == 0 && vm.canNextFromInfo {
                                    vm.step += 1
                                } else if vm.step == 1 && vm.image != nil {
                                    vm.step += 1
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Next")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .frame(height: 44)
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: 160)
                            .background((vm.step == 0 && !vm.canNextFromInfo) || (vm.step == 1 && vm.image == nil) ? SigEpTheme.purple.opacity(0.3) : SigEpTheme.purple)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .disabled(vm.step == 0 && !vm.canNextFromInfo)
                            .disabled(vm.step == 1 && vm.image == nil)
                        } else {
                            Button(action: {
                                Task { @MainActor in
                                    if let created = await vm.submit(termId: termId, api: api) {
                                        onCreate(created)
                                    }
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text(vm.saving ? "Adding…" : "Add PNM")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .frame(height: 44)
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: 180)
                            .background(vm.saving || !vm.canNextFromInfo ? SigEpTheme.purple.opacity(0.3) : SigEpTheme.purple)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .disabled(vm.saving || !vm.canNextFromInfo)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("New PNM")
            .navigationBarTitleDisplayMode(.inline)
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
            .confirmationDialog("Select Photo", isPresented: $showPickerOptions) {
                Button("Choose from Library") { showLibrary = true }
                Button("Take Photo") { showCamera = true }
                if vm.image != nil {
                    Button("Remove Photo", role: .destructive) { vm.image = nil }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.step {
        case 0:
            infoView
        case 1:
            photoView
        default:
            reviewView
        }
    }

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Info")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                labeledField(
                    title: "First name",
                    placeholder: "First name",
                    text: $vm.firstName,
                    required: true
                )

                labeledField(
                    title: "Last name",
                    placeholder: "Last name",
                    text: $vm.lastName,
                    required: true
                )

                labeledField(
                    title: "Preferred name",
                    placeholder: "Optional",
                    text: $vm.preferredName
                )
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)

            VStack(alignment: .leading, spacing: 12) {
                Text("Details")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                labeledField(
                    title: "GPA",
                    placeholder: "Optional",
                    text: $vm.gpa,
                    keyboard: .decimalPad
                )

                labeledField(
                    title: "Major",
                    placeholder: "Optional",
                    text: $vm.major
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Class year")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(vm.classYearComputed.map(String.init) ?? "-")
                            .font(.body)
                            .foregroundStyle(SigEpTheme.purple)

                        Spacer()

                        Stepper("", value: $vm.gradYearDelta, in: -6...6)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(SigEpTheme.purple.opacity(0.15), lineWidth: 1)
                    )
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)

            if let e = vm.error {
                Text(e)
                    .font(.footnote)
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var photoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Photo")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)

                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(SigEpTheme.purple.opacity(0.06))

                        if let img = vm.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "person.crop.square.badge.plus")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundStyle(SigEpTheme.purple)
                                Text("Tap to add a photo")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPickerOptions = true
                    }

                    Text("A clear headshot helps members recognize PNMs during rush events.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(16)
            }
        }
    }

    private var reviewView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Review")
                .font(.title3.weight(.semibold))

            VStack(alignment: .leading, spacing: 12) {
                Text("Info")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    reviewRow(label: "Name", value: "\(vm.preferredName.isEmpty ? vm.firstName : vm.preferredName) \(vm.lastName)")
                    if !vm.major.isEmpty {
                        reviewRow(label: "Major", value: vm.major)
                    }
                    if !vm.gpa.isEmpty {
                        reviewRow(label: "GPA", value: vm.gpa)
                    }
                    if let y = vm.classYearComputed {
                        reviewRow(label: "Class Year", value: String(y))
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    if let img = vm.image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        HStack {
                            Image(systemName: "person.crop.square")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("No photo added")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }

                    Button("Change Photo") {
                        vm.step = 1
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(SigEpTheme.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
            }
        }
    }

    private func labeledField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        required: Bool = false,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                if required {
                    Text("*")
                        .foregroundStyle(Color.red)
                        .font(.subheadline.weight(.bold))
                }
            }

            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary.opacity(0.7))
                }

                TextField("", text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .foregroundStyle(SigEpTheme.purple)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(SigEpTheme.purple.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(SigEpTheme.purple)
        }
        .font(.body)
    }
}

#Preview("Add PNM Wizard") {
    let auth = AuthStore()
    auth.accessToken = "demo"

    let api = APIClient(auth: auth)

    return AddPNMWizard(onCreate: { _ in })
        .environmentObject(api)
        .environmentObject(auth)
        .environment(\.termId, "demo-term")
}
