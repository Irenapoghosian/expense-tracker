//
//  Apperror.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 18.09.26.
//

import Foundation
 
/// Centralized, typed error model for the app.
/// Every layer (Repository, ViewModels) throws/returns this instead of
/// raw Core Data errors or ad-hoc strings, so error messages stay
/// consistent and easy to localize/test.
enum AppError: LocalizedError, Equatable {
    case invalidInput(String)
    case persistenceFailed(underlying: String)
    case notFound
 
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return message
        case .persistenceFailed:
            return "Something went wrong while saving your data. Please try again."
        case .notFound:
            return "The item you're looking for could not be found."
        }
    }
 
    /// Wraps any thrown error (e.g. from Core Data) into a persistenceFailed case,
    /// preserving the original description for logging/debugging.
    static func persistence(_ error: Error) -> AppError {
        .persistenceFailed(underlying: error.localizedDescription)
    }
}
