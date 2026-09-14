//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddTransactionViewModel

    init(repository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(repository: repository))
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
                            Text(cat.capitalized).tag(cat)
                        }
                    }
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
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

#Preview {
    AddTransactionView(repository: CoreDataTransactionRepository(context: PersistenceController.preview.container.viewContext))
}
