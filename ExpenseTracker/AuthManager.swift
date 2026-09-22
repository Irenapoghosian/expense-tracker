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

    static let securityQuestions = [
        "What was the name of your first pet?",
        "What is your mother's maiden name?",
        "What city were you born in?",
        "What was your childhood nickname?"
    ]

    private let registeredUsersKey = "registeredUsernames"
    private let loggedInUserKey = "loggedInUsername"
    private let displayNamePrefix = "displayName_"
    private let securityQuestionPrefix = "securityQuestion_"

    init() {
        currentUsername = UserDefaults.standard.string(forKey: loggedInUserKey)
    }

    // MARK: - Local accounts

    private var registeredUsernames: [String] {
        get { UserDefaults.standard.stringArray(forKey: registeredUsersKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: registeredUsersKey) }
    }

    private func hash(_ text: String, salt: String) -> String {
        let salted = "\(salt.lowercased()):\(text):ExpenseTrackerSalt"
        let digest = SHA256.hash(data: Data(salted.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func hash(_ password: String, username: String) -> String {
        hash(password, salt: username)
    }

    private func isValidUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    private func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 6 else { return false }
        let hasUppercase = password.contains { $0.isUppercase }
        let hasDigit = password.contains { $0.isNumber }
        return hasUppercase && hasDigit
    }

    @discardableResult
    func register(
        username: String,
        password: String,
        confirmPassword: String,
        securityQuestion: String,
        securityAnswer: String
    ) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = securityAnswer.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !password.isEmpty, !trimmedAnswer.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return false
        }
        guard trimmedUsername.count >= 3 else {
            errorMessage = AuthError.usernameTooShort.errorDescription
            return false
        }
        guard isValidUsername(trimmedUsername) else {
            errorMessage = AuthError.invalidUsernameCharacters.errorDescription
            return false
        }
        guard isStrongPassword(password) else {
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

        let hashedPassword = hash(password, username: trimmedUsername)
        guard KeychainHelper.save(hashedPassword, account: trimmedUsername.lowercased()) else {
            errorMessage = "Could not save your account. Please try again."
            return false
        }

        let hashedAnswer = hash(trimmedAnswer.lowercased(), salt: "\(trimmedUsername)_security")
        KeychainHelper.save(hashedAnswer, account: "security_\(trimmedUsername.lowercased())")
        UserDefaults.standard.set(securityQuestion, forKey: securityQuestionPrefix + trimmedUsername.lowercased())

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
        guard isStrongPassword(newPassword) else {
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

    // MARK: - Forgot password

    func securityQuestion(for username: String) -> String? {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedUsername.isEmpty,
              KeychainHelper.read(account: "security_\(trimmedUsername)") != nil else {
            return nil
        }
        return UserDefaults.standard.string(forKey: securityQuestionPrefix + trimmedUsername)
    }

    @discardableResult
    func resetPassword(username: String, securityAnswer: String, newPassword: String, confirmPassword: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !securityAnswer.isEmpty else {
            errorMessage = AuthError.emptyFields.errorDescription
            return false
        }
        guard let storedAnswerHash = KeychainHelper.read(account: "security_\(trimmedUsername.lowercased())") else {
            errorMessage = AuthError.usernameNotFound.errorDescription
            return false
        }
        let providedHash = hash(securityAnswer.trimmingCharacters(in: .whitespaces).lowercased(), salt: "\(trimmedUsername)_security")
        guard storedAnswerHash == providedHash else {
            errorMessage = AuthError.securityAnswerIncorrect.errorDescription
            return false
        }
        guard isStrongPassword(newPassword) else {
            errorMessage = AuthError.weakPassword.errorDescription
            return false
        }
        guard newPassword == confirmPassword else {
            errorMessage = AuthError.passwordsDoNotMatch.errorDescription
            return false
        }

        let newHash = hash(newPassword, username: trimmedUsername)
        guard KeychainHelper.save(newHash, account: trimmedUsername.lowercased()) else {
            errorMessage = "Could not update your password. Please try again."
            return false
        }

        errorMessage = nil
        return true
    }

    // MARK: - Account deletion

    func deleteAccount(profileManager: ProfileManager) {
        guard let username = currentUsername else { return }

        KeychainHelper.delete(account: username.lowercased())
        KeychainHelper.delete(account: "security_\(username.lowercased())")
        UserDefaults.standard.removeObject(forKey: securityQuestionPrefix + username.lowercased())
        registeredUsernames.removeAll { $0.caseInsensitiveCompare(username) == .orderedSame }
        profileManager.deleteAllData(for: username)

        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
        currentUsername = nil
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
        currentUsername = username
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
        currentUsername = nil
    }
}
