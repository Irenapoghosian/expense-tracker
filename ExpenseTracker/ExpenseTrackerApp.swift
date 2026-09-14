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
            ContentView(repository: CoreDataTransactionRepository(context: persistenceController.container.viewContext))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }

    }
}
