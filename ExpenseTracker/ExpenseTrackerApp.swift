//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import SwiftUI
import CoreData

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
