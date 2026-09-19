//
//  UserProfile.swift
//  ExpenseTracker
//

import Foundation

struct UserProfile: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var birthday: Date?
}
