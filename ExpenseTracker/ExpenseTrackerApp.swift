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
                let repository = CoreDataTransactionRepository(context: persistenceController.container.viewContext)
                
                TabView {
                    ContentView(repository: repository)
                        .tabItem {
                            Label("Expenses", systemImage: "list.bullet")
                        }
                    
                    CategoryBreakdownView(repository: repository)
                        .tabItem {
                            Label("Breakdown", systemImage: "chart.pie")
                        }
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
