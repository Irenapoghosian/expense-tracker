import SwiftUI
import UIKit
import CoreData

private struct TransactionRow: View {
    let transaction: TransactionEntity

    var body: some View {
        let category = Category.from(transaction.category)
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(category.color)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title ?? "Untitled")
                    .font(.headline)
                Text(category.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.body.weight(.medium))
        }
        .padding(.vertical, 4)
        .transition(rowTransition)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title ?? "Untitled"), \(category.displayName)")
        .accessibilityValue(Text(transaction.amount, format: .currency(code: "USD")))
    }

    private var rowTransition: AnyTransition {
        let insertion: AnyTransition = .move(edge: .trailing).combined(with: .opacity)
        let removal: AnyTransition = .move(edge: .leading).combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

private struct EmptyTransactionsView: View {
    let hasSearchText: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: hasSearchText ? "magnifyingglass" : "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text(hasSearchText ? "No matching transactions" : "No transactions yet")
                .font(.headline)
            Text(hasSearchText ? "Try a different search term" : "Tap + to add your first expense")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .accessibilityElement(children: .combine)
    }
}

private struct SortMenu: View {
    @Binding var sortOption: TransactionSortOption

    var body: some View {
        Menu {
            ForEach(TransactionSortOption.allCases) { option in
                Button(action: { sortOption = option }, label: {
                    Label(option.label, systemImage: option.icon)
                    if sortOption == option {
                        Image(systemName: "checkmark")
                    }
                })
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort transactions")
        .accessibilityHint("Currently sorted: \(sortOption.label)")
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TransactionListViewModel
    @State private var showingAddTransaction = false
    @State private var transactionToEdit: TransactionEntity?
    @State private var addButtonPressed = false
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    @State private var showingExportError = false
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: TransactionListViewModel(repository: repository))
    }

    private var totalAmountText: some View {
        Text(viewModel.totalAmount, format: .currency(code: "USD"))
            .font(.headline)
            .animation(.easeInOut(duration: 0.3), value: viewModel.totalAmount)
    }

    private var rowAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }

    private func handleAddTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            addButtonPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                addButtonPressed = false
            }
        }
        showingAddTransaction = true
    }

    private func handleDelete(at offsets: IndexSet) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.deleteTransactions(at: offsets)
        }
    }

    private func handleExportTapped() {
        guard let url = CSVExporter.exportToTemporaryFile(transactions: viewModel.filteredTransactions) else {
            showingExportError = true
            return
        }
        exportURL = url
        showingShareSheet = true
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Category", selection: $viewModel.selectedCategory.animation(.easeInOut)) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        Text(cat.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .accessibilityLabel("Filter by category")

                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    totalAmountText
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)

                if viewModel.filteredTransactions.isEmpty {
                    Spacer()
                    EmptyTransactionsView(hasSearchText: !viewModel.searchText.isEmpty)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    transactionToEdit = transaction
                                }
                                .accessibilityAddTraits(.isButton)
                                .accessibilityHint("Double tap to edit")
                        }
                        .onDelete(perform: handleDelete)
                    }
                    .animation(
                        rowAnimation,
                        value: viewModel.filteredTransactions.map(\.objectID)
                    )
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: handleExportTapped, label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    })
                    .disabled(viewModel.filteredTransactions.isEmpty)
                    .accessibilityHint("Exports the visible transactions as a CSV file")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    SortMenu(sortOption: $viewModel.sortOption)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: handleAddTapped, label: {
                        Label("Add Transaction", systemImage: "plus")
                    })
                    .scaleEffect(addButtonPressed ? 1.3 : 1.0)
                }
            }
            .sheet(isPresented: $showingAddTransaction, onDismiss: {
                viewModel.fetchTransactions()
            }, content: {
                AddTransactionView(repository: repository)
            })
            .sheet(item: $transactionToEdit, onDismiss: {
                viewModel.fetchTransactions()
            }, content: { transaction in
                EditTransactionView(transaction: transaction, repository: repository)
            })
            .sheet(isPresented: $showingShareSheet, content: {
                if let exportURL {
                    ShareSheet(activityItems: [exportURL])
                }
            })
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Export Failed", isPresented: $showingExportError) {
                Button("OK") { showingExportError = false }
            } message: {
                Text("Could not create the CSV file. Please try again.")
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.filteredTransactions.isEmpty)
        }
    }
}

#Preview {
    ContentView(repository: CoreDataTransactionRepository(context: PersistenceController.preview.container.viewContext))
}
