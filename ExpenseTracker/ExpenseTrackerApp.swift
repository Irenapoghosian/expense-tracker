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
    @StateObject private var persistenceController = PersistenceController.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @StateObject private var authManager = AuthManager()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            let repository = CoreDataTransactionRepository(context: persistenceController.container.viewContext)

            Group {
                if authManager.currentUsername != nil {
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
                    .id(authManager.currentUsername)
                    .fullScreenCover(isPresented: .init(
                        get: { !hasSeenOnboarding },
                        set: { hasSeenOnboarding = !$0 }
                    )) {
                        OnboardingView(isPresented: .init(
                            get: { !hasSeenOnboarding },
                            set: { hasSeenOnboarding = !$0 }
                        ))
                    }
                } else {
                    LoginView()
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(authManager)
            .environmentObject(profileManager)
            .preferredColorScheme(appTheme.colorScheme)
            .onAppear {
                persistenceController.switchStore(to: authManager.currentUsername)
                if let username = authManager.currentUsername {
                    profileManager.load(for: username)
                }
            }
            .onChange(of: authManager.currentUsername) { _, newUsername in
                persistenceController.switchStore(to: newUsername)
                if let newUsername {
                    profileManager.load(for: newUsername)
                } else {
                    profileManager.clear()
                }
            }
        }
    }
}
