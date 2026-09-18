//
//  SetBudgetView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import SwiftUI

struct SetBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var selectedCategory: String = "food"
    @State private var limitText: String = ""
    
    var isValid: Bool {
        Double(limitText).map { $0 > 0 } ?? false
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            Label(Category.from(cat).displayName, systemImage: Category.from(cat).icon)
                                .tag(cat)
                        }
                    }
                    
                    TextField("Monthly limit", text: $limitText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Set budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let limit = Double(limitText) {
                            viewModel.setBudget(category: selectedCategory, limit: limit)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
