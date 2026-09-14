//
//  EditTransactionView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import SwiftUI
import CoreData


struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditTransactionViewModel

    init(transaction: TransactionEntity, repository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: EditTransactionViewModel(transaction: transaction, repository: repository))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $viewModel.title)
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            Label(Category.from(cat).displayName, systemImage: Category.from(cat).icon)
                                .tag(cat)
                        }
                    }
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
