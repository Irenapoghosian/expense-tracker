import CoreData
import Combine

extension Notification.Name {
    static let dataStoreDidChange = Notification.Name("dataStoreDidChange")
}

final class PersistenceController: ObservableObject {
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

    @Published private(set) var container: NSPersistentContainer
    private let isTemplateInMemory: Bool
    private var remoteChangeObserver: NSObjectProtocol?
    private var currentUsername: String?
    private var hasSwitchedOnce = false

    init(inMemory: Bool = false) {
        self.isTemplateInMemory = inMemory
        self.container = Self.makeContainer(inMemory: inMemory, username: nil)
        Self.loadStores(for: container)
        Self.configureContext(container.viewContext)

        if !inMemory {
            remoteChangeObserver = Self.observeRemoteChanges(for: container)
        }
    }

    private static func storeURL(for username: String) -> URL? {
        let safeName = username.lowercased()
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory.appendingPathComponent("ExpenseTracker_\(safeName).sqlite")
    }

    private static func makeContainer(inMemory: Bool, username: String?) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "ExpenseTracker")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            if let username, let url = storeURL(for: username), let description = container.persistentStoreDescriptions.first {
                description.url = url
            }
            if let description = container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }
        }
        return container
    }

    private static func loadStores(for container: NSPersistentContainer) {
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    private static func configureContext(_ context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func observeRemoteChanges(for container: NSPersistentContainer) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main
        ) { _ in
            NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
        }
    }

    /// Switches to the given user's private database. Pass `nil` when logged out.
    func switchStore(to username: String?) {
        if hasSwitchedOnce, username == currentUsername { return }
        hasSwitchedOnce = true
        currentUsername = username

        if let remoteChangeObserver {
            NotificationCenter.default.removeObserver(remoteChangeObserver)
            self.remoteChangeObserver = nil
        }

        let useInMemory = isTemplateInMemory || username == nil
        let newContainer = Self.makeContainer(inMemory: useInMemory, username: username)
        Self.loadStores(for: newContainer)
        Self.configureContext(newContainer.viewContext)

        if !useInMemory {
            remoteChangeObserver = Self.observeRemoteChanges(for: newContainer)
        }

        container = newContainer
    }
}
