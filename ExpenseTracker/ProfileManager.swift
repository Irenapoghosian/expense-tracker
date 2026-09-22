//
//  ProfileManager.swift
//  ExpenseTracker
//

import Foundation
import Combine
import SwiftUI

final class ProfileManager: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var birthday: Date?
    @Published var profileImage: UIImage?

    private var username: String?
    private let fileManager = FileManager.default

    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name
    }

    func load(for username: String) {
        self.username = username
        let key = profileKey(for: username)
        if let data = UserDefaults.standard.data(forKey: key),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            firstName = profile.firstName
            lastName = profile.lastName
            email = profile.email
            birthday = profile.birthday
        } else {
            firstName = ""
            lastName = ""
            email = ""
            birthday = nil
        }
        profileImage = loadImage(for: username)
    }

    func save(firstName: String, lastName: String, email: String, birthday: Date?, image: UIImage?) {
        guard let username else { return }
        let profile = UserProfile(firstName: firstName, lastName: lastName, email: email, birthday: birthday)
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey(for: username))
        }
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthday = birthday

        if let image {
            saveImage(image, for: username)
            profileImage = image
        }
    }

    func clear() {
        username = nil
        firstName = ""
        lastName = ""
        email = ""
        birthday = nil
        profileImage = nil
    }

    func deleteAllData(for username: String) {
        UserDefaults.standard.removeObject(forKey: profileKey(for: username))
        if let url = imageURL(for: username) {
            try? fileManager.removeItem(at: url)
        }
        clear()
    }

    private func profileKey(for username: String) -> String {
        "userProfile_\(username.lowercased())"
    }

    private func imageURL(for username: String) -> URL? {
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let folder = documents.appendingPathComponent("ProfileImages", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent("\(username.lowercased()).jpg")
    }

    private func saveImage(_ image: UIImage, for username: String) {
        guard let url = imageURL(for: username), let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: url)
    }

    private func loadImage(for username: String) -> UIImage? {
        guard let url = imageURL(for: username), let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
