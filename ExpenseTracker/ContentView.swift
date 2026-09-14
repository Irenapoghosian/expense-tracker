//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TransactionListViewModel
    @State private var showingAddTransaction = false
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: TransactionListViewModel(repository: repository))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        Text(cat.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.totalAmount, format: .currency(code: "USD"))
                        .font(.headline)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                if viewModel.filteredTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No transactions yet")
                            .font(.headline)
                        Text("Tap + to add your first expense")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(transaction.title ?? "Untitled")
                                        .font(.headline)
                                    Text(transaction.category ?? "other")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(transaction.amount, format: .currency(code: "USD"))
                                    .font(.body)
                            }
                        }
                        .onDelete(perform: viewModel.deleteTransactions)
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddTransaction = true }) {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction, onDismiss: {
                viewModel.fetchTransactions()
            }) {
                AddTransactionView(repository: repository)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ContentView(repository: CoreDataTransactionRepository(context: PersistenceController.preview.container.viewContext))
}
