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
    @State private var transactionToEdit: TransactionEntity?
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
                            let category = Category.from(transaction.category)
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(category.color)
                                    .clipShape(Circle())
                                
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                transactionToEdit = transaction
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
            .sheet(item: $transactionToEdit, onDismiss: {
                viewModel.fetchTransactions()
            }) { transaction in
                EditTransactionView(transaction: transaction, repository: repository)
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
