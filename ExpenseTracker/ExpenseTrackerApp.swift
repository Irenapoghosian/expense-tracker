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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            let repository = CoreDataTransactionRepository(context: persistenceController.container.viewContext)

            TabView {
                ContentView(repository: repository)
                    .tabItem {
                        Label("Expenses", systemImage: "list.bullet")
                    }

                BudgetView(repository: repository)
                    .tabItem {
                        Label("Budgets", systemImage: "chart.pie")
                    }

                CategoryBreakdownView(repository: repository)
                    .tabItem {
                        Label("Breakdown", systemImage: "chart.pie")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(appTheme.colorScheme)
            .fullScreenCover(isPresented: .init(
                get: { !hasSeenOnboarding },
                set: { hasSeenOnboarding = !$0 }
            )) {
                OnboardingView(isPresented: .init(
                    get: { !hasSeenOnboarding },
                    set: { hasSeenOnboarding = !$0 }
                ))
            }
        }
    }
}
