//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

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
    }
 
    private var rowTransition: AnyTransition {
        let insertion: AnyTransition = .move(edge: .trailing).combined(with: .opacity)
        let removal: AnyTransition = .move(edge: .leading).combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
 
private struct EmptyTransactionsView: View {
    var body: some View {
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
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}
 
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TransactionListViewModel
    @State private var showingAddTransaction = false
    @State private var transactionToEdit: TransactionEntity?
    @State private var addButtonPressed = false
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
 
                HStack {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    totalAmountText
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
 
                if viewModel.filteredTransactions.isEmpty {
                    Spacer()
                    EmptyTransactionsView()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    transactionToEdit = transaction
                                }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: handleAddTapped) {
                        Label("Add Transaction", systemImage: "plus")
                    }
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
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.filteredTransactions.isEmpty)
        }
    }
}
 
#Preview {
    ContentView(repository: CoreDataTransactionRepository(context: PersistenceController.preview.container.viewContext))
}
