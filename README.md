# ExpenseTracker

A simple, native iOS app for tracking personal expenses, built with **SwiftUI** and **Core Data**.

## Features

- ➕ Add new transactions with title, amount, category, and date
- 📋 View all transactions in a sortable, filterable list
- 🗂 Filter transactions by category (Food, Transport, Entertainment, Bills, Other)
- 💰 See the total amount for the currently selected category
- 🗑 Swipe-to-delete transactions
- ✅ Input validation (non-empty title, positive numeric amount)
- 🧪 Unit tested view models with an in-memory Core Data stack

## Architecture

The app follows an **MVVM** architecture on top of Core Data:

```
ExpenseTracker/
├── ViewModels/
│   ├── AddTransactionViewModel.swift     # Validation + save logic for new transactions
│   └── TransactionListViewModel.swift    # Fetching, filtering, totals, deletion
├── ExpenseTracker/
│   ├── AddTransactionView.swift          # Form for creating a transaction
│   ├── ContentView.swift                 # Main list + filter + total UI
│   ├── ExpenseTrackerApp.swift           # App entry point
│   ├── Persistence.swift                 # Core Data stack (NSPersistentContainer)
│   └── ExpenseTracker.xcdatamodeld       # Core Data model (TransactionEntity)
└── ExpenseTrackerTests/
    ├── AddTransactionViewModelTests.swift
    └── ExpenseTrackerTests.swift         # TransactionListViewModel tests
```

### Data Model

**TransactionEntity**

| Attribute | Type   |
|-----------|--------|
| id        | UUID   |
| title     | String |
| amount    | Double |
| category  | String |
| date      | Date   |

## Requirements

- Xcode 15+
- iOS 16+
- Swift 5.9+

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Irenapoghosian/expense-tracker.git
   ```
2. Open `ExpenseTracker.xcodeproj` in Xcode.
3. Build and run on a simulator or device (`⌘R`).

## Running Tests

Run the full test suite with `⌘U` in Xcode, or from the command line:

```bash
xcodebuild test \
  -project ExpenseTracker.xcodeproj \
  -scheme ExpenseTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests cover:
- `AddTransactionViewModel`: validation rules and save behavior
- `TransactionListViewModel`: fetching, category filtering, total calculation, deletion

## Roadmap

- [ ] Edit existing transactions
- [ ] Charts / spending breakdown by category
- [ ] iCloud sync via `NSPersistentCloudKitContainer`
- [ ] Localization

## License

This project is currently unlicensed. Add a license file if you plan to open-source it.
