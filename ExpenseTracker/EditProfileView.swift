//
//  EditProfileView.swift
//  ExpenseTracker
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var birthday: Date = Date()
    @State private var hasBirthday: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                if let selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }
                            }
                            Text("Change Photo")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Your Name")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.oneTimeCode)

                    TextField("Last Name", text: $lastName)
                        .textContentType(.oneTimeCode)
                }

                Section(header: Text("Contact Info")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.oneTimeCode)
                }

                Section(header: Text("Birthday")) {
                    Toggle("Add Birthday", isOn: $hasBirthday)
                    if hasBirthday {
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profileManager.save(
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            lastName: lastName.trimmingCharacters(in: .whitespaces),
                            email: email,
                            birthday: hasBirthday ? birthday : nil,
                            image: selectedImage
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                firstName = profileManager.firstName
                lastName = profileManager.lastName
                email = profileManager.email
                if let existingBirthday = profileManager.birthday {
                    birthday = existingBirthday
                    hasBirthday = true
                }
                selectedImage = profileManager.profileImage
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileManager())
}
