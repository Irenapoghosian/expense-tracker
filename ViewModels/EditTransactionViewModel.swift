//
//  EditTransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import Foundation
import CoreData
import Combine


final class EditTransactionViewModel: ObservableObject {
    @Published var title: String
    @Published var amount: String
    @Published var category: String
    @Published var date: Date
    @Published var errorMessage: String?
    
    let categories = ["food", "transport", "entertainment", "bills", "other"]
    
    private let repository: TransactionRepository
    private let transaction: TransactionEntity
    
    init(transaction: TransactionEntity, repository: TransactionRepository) {
        self.transaction = transaction
        self.repository = repository
        self.title = transaction.title ?? ""
        self.amount = String(transaction.amount)
        self.category = transaction.category ?? "food"
        self.date = transaction.date ?? Date()
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
        
        transaction.title = title.trimmingCharacters(in: .whitespaces)
        transaction.amount = Double(amount) ?? 0
        transaction.category = category
        transaction.date = date
        
        do {
            try repository.save(transaction)
            return true
        } catch {
            errorMessage = "Couldn't save changes. Please try again."
            return false
        }
    }
}
