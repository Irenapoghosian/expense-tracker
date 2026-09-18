//
//  AddTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import Foundation
import CoreData
import Combine

final class AddTransactionViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var amount: String = ""
    @Published var category: String = "food"
    @Published var date = Date()
    @Published var errorMessage: String?
    
    let categories = ["food", "transport", "entertainment", "bills", "other"]
    
    private let repository: TransactionRepository
    
    init(repository: TransactionRepository) {
        self.repository = repository
    }
    
    var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard let value = Double(amount), value > 0 else { return false }
        return true
    }
    
    func save() -> Bool {
        guard isValid else {
            errorMessage = "Please enter a title and a valid amount greater than 0."
            return false
        }
        
        let newTransaction = repository.makeNewTransaction()
        newTransaction.id = UUID()
        newTransaction.title = title.trimmingCharacters(in: .whitespaces)
        newTransaction.amount = Double(amount) ?? 0
        newTransaction.category = category
        newTransaction.date = date
        
        do {
            try repository.save(newTransaction)
            return true
        } catch {
            errorMessage = "Couldn't save transaction. Please try again."
            return false
        }
    }
}
