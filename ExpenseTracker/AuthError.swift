//
//  AuthError.swift
//  ExpenseTracker
//

import Foundation

enum AuthError: LocalizedError {
    case usernameTaken
    case usernameNotFound
    case invalidCredentials
    case weakPassword
    case passwordsDoNotMatch
    case emptyFields
    case appleSignInFailed
    case usernameTooShort
    case invalidUsernameCharacters
    case securityAnswerIncorrect

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "This username is already taken."
        case .usernameNotFound:
            return "No account found with that username."
        case .invalidCredentials:
            return "Incorrect username or password."
        case .weakPassword:
            return "Password must be at least 6 characters, with at least one uppercase letter and one number."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .emptyFields:
            return "Please fill in all fields."
        case .appleSignInFailed:
            return "Sign in with Apple failed. Please try again."
        case .usernameTooShort:
            return "Username must be at least 3 characters."
        case .invalidUsernameCharacters:
            return "Username can only contain letters, numbers, and underscores."
        case .securityAnswerIncorrect:
            return "That answer doesn't match our records."
        }
    }
}
