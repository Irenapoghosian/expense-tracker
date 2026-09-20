//
//  AuthError.swift
//  ExpenseTracker
//

import Foundation

enum AuthError: LocalizedError, Equatable {
    case usernameTaken
    case usernameNotFound
    case invalidCredentials
    case weakPassword
    case passwordsDoNotMatch
    case emptyFields
    case appleSignInFailed

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "That username is already taken. Try a different one."
        case .usernameNotFound:
            return "No account found with that username."
        case .invalidCredentials:
            return "Incorrect username or password."
        case .weakPassword:
            return "Password must be at least 6 characters long."
        case .passwordsDoNotMatch:
            return "Passwords don't match."
        case .emptyFields:
            return "Please fill in all fields."
        case .appleSignInFailed:
            return "Sign in with Apple failed. Please try again."
        }
    }
}
