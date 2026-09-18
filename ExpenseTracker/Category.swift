//
//  Category.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//

import SwiftUI

enum Category: String, CaseIterable {
    case food, transport, entertainment, bills, other
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .bills: return "doc.text.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .bills: return .red
        case .other: return .gray
        }
    }
    
    static func from(_ raw: String?) -> Category {
        Category(rawValue: raw ?? "other") ?? .other
    }
}
