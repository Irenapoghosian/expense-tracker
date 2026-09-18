//
//  Persistence.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import CoreData
import Combine

extension Notification.Name {
    static let dataStoreDidChange = Notification.Name("dataStoreDidChange")
}

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = TransactionEntity(context: viewContext)
            newItem.id = UUID()
            newItem.title = "Sample \(i)"
            newItem.amount = Double(i) * 10
            newItem.category = "food"
            newItem.date = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    private var remoteChangeObserver: NSObjectProtocol?

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExpenseTracker")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Պատրաստում ենք history tracking-ը, useful է remote-change listener-ի,
            // ինչպես նաև ապագա CloudKit sync-ի համար
            if let description = container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        if !inMemory {
            NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: container.persistentStoreCoordinator,
                queue: .main
            ) { _ in
                NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
            }
        }
    }
}
