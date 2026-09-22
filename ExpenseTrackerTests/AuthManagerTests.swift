//
//  AuthManagerTests.swift
//  ExpenseTrackerTests
//

import XCTest
@testable import ExpenseTracker

final class AuthManagerTests: XCTestCase {
    private var authManager: AuthManager!

    override func setUp() {
        super.setUp()
        authManager = AuthManager()
    }

    override func tearDown() {
        authManager = nil
        super.tearDown()
    }

    private func uniqueUsername() -> String {
        "test_\(UUID().uuidString.prefix(8))"
    }

    // MARK: - Register

    func testRegisterSucceedsWithValidInput() {
        let username = uniqueUsername()
        let success = authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertTrue(success)
        XCTAssertNil(authManager.errorMessage)
    }

    func testRegisterFailsWithWeakPassword() {
        let username = uniqueUsername()
        let success = authManager.register(
            username: username,
            password: "password",
            confirmPassword: "password",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.weakPassword.errorDescription)
    }

    func testRegisterFailsWithShortUsername() {
        let success = authManager.register(
            username: "ab",
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.usernameTooShort.errorDescription)
    }

    func testRegisterFailsWithInvalidUsernameCharacters() {
        let success = authManager.register(
            username: "invalid username!",
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.invalidUsernameCharacters.errorDescription)
    }

    func testRegisterFailsWithMismatchedPasswords() {
        let username = uniqueUsername()
        let success = authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password2",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.passwordsDoNotMatch.errorDescription)
    }

    func testRegisterFailsWithDuplicateUsername() {
        let username = uniqueUsername()
        XCTAssertTrue(authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        ))

        let secondManager = AuthManager()
        let success = secondManager.register(
            username: username,
            password: "Password2",
            confirmPassword: "Password2",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(secondManager.errorMessage, AuthError.usernameTaken.errorDescription)
    }

    // MARK: - Login

    func testLoginSucceedsWithCorrectCredentials() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        authManager.logout()

        let success = authManager.login(username: username, password: "Password1")
        XCTAssertTrue(success)
        XCTAssertNil(authManager.errorMessage)
    }

    func testLoginFailsWithWrongPassword() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        authManager.logout()

        let success = authManager.login(username: username, password: "WrongPassword1")
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.invalidCredentials.errorDescription)
    }

    func testLoginFailsWithUnknownUsername() {
        let success = authManager.login(username: uniqueUsername(), password: "Password1")
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.usernameNotFound.errorDescription)
    }

    // MARK: - Logout

    func testLogoutClearsCurrentUsername() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        XCTAssertEqual(authManager.currentUsername, username)

        authManager.logout()
        XCTAssertNil(authManager.currentUsername)
    }

    // MARK: - Change password

    func testChangePasswordSucceeds() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )

        let success = authManager.changePassword(
            currentPassword: "Password1",
            newPassword: "NewPassword2",
            confirmPassword: "NewPassword2"
        )
        XCTAssertTrue(success)

        authManager.logout()
        XCTAssertTrue(authManager.login(username: username, password: "NewPassword2"))
    }

    func testChangePasswordFailsWithWrongCurrentPassword() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )

        let success = authManager.changePassword(
            currentPassword: "WrongPassword1",
            newPassword: "NewPassword2",
            confirmPassword: "NewPassword2"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, "Current password is incorrect.")
    }

    // MARK: - Forgot password

    func testResetPasswordWithCorrectSecurityAnswer() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        authManager.logout()

        XCTAssertEqual(authManager.securityQuestion(for: username), AuthManager.securityQuestions[0])

        let success = authManager.resetPassword(
            username: username,
            securityAnswer: "Fluffy",
            newPassword: "ResetPass1",
            confirmPassword: "ResetPass1"
        )
        XCTAssertTrue(success)
        XCTAssertTrue(authManager.login(username: username, password: "ResetPass1"))
    }

    func testResetPasswordFailsWithWrongSecurityAnswer() {
        let username = uniqueUsername()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )
        authManager.logout()

        let success = authManager.resetPassword(
            username: username,
            securityAnswer: "WrongAnswer",
            newPassword: "ResetPass1",
            confirmPassword: "ResetPass1"
        )
        XCTAssertFalse(success)
        XCTAssertEqual(authManager.errorMessage, AuthError.securityAnswerIncorrect.errorDescription)
    }

    // MARK: - Delete account

    func testDeleteAccountRemovesCredentials() {
        let username = uniqueUsername()
        let profileManager = ProfileManager()
        authManager.register(
            username: username,
            password: "Password1",
            confirmPassword: "Password1",
            securityQuestion: AuthManager.securityQuestions[0],
            securityAnswer: "Fluffy"
        )

        authManager.deleteAccount(profileManager: profileManager)
        XCTAssertNil(authManager.currentUsername)

        let loginAttempt = AuthManager()
        XCTAssertFalse(loginAttempt.login(username: username, password: "Password1"))
        XCTAssertEqual(loginAttempt.errorMessage, AuthError.usernameNotFound.errorDescription)
    }
}
