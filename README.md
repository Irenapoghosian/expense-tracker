# ExpenseTracker

A native iOS app for tracking personal expenses, built with SwiftUI, Core Data, and the MVVM + Repository architecture pattern.

## Features

- Add new transactions with title, amount, category, and date
- Edit existing transactions
- View all transactions in a sortable, filterable list
- Filter transactions by category (Food, Transport, Entertainment, Bills, Other)
- Visual spending breakdown by category with an interactive pie chart
- See the total amount for the currently selected category
- Color-coded categories with SF Symbol icons
- Swipe-to-delete transactions
- Input validation (non-empty title, positive numeric amount)
- Fully unit tested view models using an in-memory Core Data stack and dependency injection

## Architecture

The app follows MVVM with a Repository layer that abstracts Core Data behind a protocol, making the view models fully unit-testable without touching the persistence framework directly.

### Why a Repository layer?

View models depend on the TransactionRepository protocol, not on NSManagedObjectContext directly. This means:
- Tests use a real in-memory Core Data stack behind the same protocol, no mocking framework needed
- The persistence layer could be swapped out without touching any view model
- Each view model has a single, clear responsibility

### Data Model

TransactionEntity

| Attribute | Type   |
|-----------|--------|
| id        | UUID   |
| title     | String |
| amount    | Double |
| category  | String |
| date      | Date   |

## Requirements

- Xcode 15+
- iOS 16+ (uses the Charts framework)
- Swift 5.9+

## Getting Started

1. Clone the repository: git clone https://github.com/Irenapoghosian/expense-tracker.git
2. Open ExpenseTracker.xcodeproj in Xcode.
3. Build and run on a simulator or device (Cmd+R).

## Running Tests

Run the full test suite with Cmd+U in Xcode.

Tests cover:
- AddTransactionViewModel: validation rules and save behavior
- EditTransactionViewModel: field population and update behavior
- TransactionListViewModel: fetching, category filtering, total calculation, deletion
- CategoryBreakdownViewModel: grouping, summing, and sorting by category

## Roadmap

- iCloud sync via NSPersistentCloudKitContainer
- Monthly/weekly spending trends
- Localization
- Budget goals per category

## License

This project is currently unlicensed.
