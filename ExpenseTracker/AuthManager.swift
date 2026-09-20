//
//  AuthManager.swift
//  ExpenseTracker
//

import Foundation
import Combine
import CryptoKit
import AuthenticationServices

final class AuthManager: ObservableObject {
    @Published var currentUsername: String?
    @Published var errorMessage: String?

    private let registeredUsersKey = "registeredUsernames"
    private let loggedInUserKey = "loggedInUsername"
    private let displayNamePrefix = "displayName_"

    init() {
        currentUsername = UserDefaults.standard.string(forKey: loggedInUserKey)
    }

    // MARK: - Local accounts

    private var registeredUsernames: [String] {
        get { UserDefaults.standard.stringArray(forKey: registeredUsersKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: registeredUsersKey) }
    }

    private func hash(_ password: String, username: String) -> String {
        let salted = "\(username.lowercased()):\(password):ExpenseTrackerSalt"
        let digest = SHA256.hash(data: Data(salted.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    @discardableResult
    func register(username: String, password: String, confirmPassword: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return false
        }
        guard password.count >= 6 else {
            errorMessage = AuthError.weakPassword.errorDescription
            return false
        }
        guard password == confirmPassword else {
            errorMessage = AuthError.passwordsDoNotMatch.errorDescription
            return false
        }
        guard !registeredUsernames.contains(where: { $0.caseInsensitiveCompare(trimmedUsername) == .orderedSame }) else {
            errorMessage = AuthError.usernameTaken.errorDescription
            return false
        }

        let hashed = hash(password, username: trimmedUsername)
        guard KeychainHelper.save(hashed, account: trimmedUsername.lowercased()) else {
            errorMessage = "Could not save your account. Please try again."
            return false
        }

        registeredUsernames.append(trimmedUsername)
        errorMessage = nil
        signIn(username: trimmedUsername)
        return true
    }

    @discardableResult
    func login(username: String, password: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return false
        }
        guard let storedHash = KeychainHelper.read(account: trimmedUsername.lowercased()) else {
            errorMessage = AuthError.usernameNotFound.errorDescription
            return false
        }
        guard storedHash == hash(password, username: trimmedUsername) else {
            errorMessage = AuthError.invalidCredentials.errorDescription
            return false
        }

        errorMessage = nil
        signIn(username: trimmedUsername)
        return true
    }

    @discardableResult
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) -> Bool {
        guard let username = currentUsername else {
            errorMessage = AuthError.usernameNotFound.errorDescription
            return false
        }
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return false
        }
        guard let storedHash = KeychainHelper.read(account: username.lowercased()) else {
            errorMessage = "Password change is only available for local accounts."
            return false
        }
        guard storedHash == hash(currentPassword, username: username) else {
            errorMessage = "Current password is incorrect."
            return false
        }
        guard newPassword.count >= 6 else {
            errorMessage = AuthError.weakPassword.errorDescription
            return false
        }
        guard newPassword == confirmPassword else {
            errorMessage = AuthError.passwordsDoNotMatch.errorDescription
            return false
        }

        let newHash = hash(newPassword, username: username)
        guard KeychainHelper.save(newHash, account: username.lowercased()) else {
            errorMessage = "Could not update your password. Please try again."
            return false
        }

        errorMessage = nil
        return true
    }

    // MARK: - Sign in with Apple

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = AuthError.appleSignInFailed.errorDescription
                return
            }

            let userID = credential.user
            let displayName: String
            if let fullName = credential.fullName,
               let given = fullName.givenName, !given.isEmpty {
                displayName = given
            } else {
                displayName = UserDefaults.standard.string(forKey: displayNamePrefix + userID) ?? "Apple User"
            }
            UserDefaults.standard.set(displayName, forKey: displayNamePrefix + userID)

            errorMessage = nil
            signIn(username: displayName)
        case .failure:
            errorMessage = AuthError.appleSignInFailed.errorDescription
        }
    }

    // MARK: - Session

    private func signIn(username: String) {
        UserDefaults.standard.set(username, forKey: loggedInUserKey)
        DispatchQueue.main.async {
            self.currentUsername = username
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
        currentUsername = nil
    }
}
