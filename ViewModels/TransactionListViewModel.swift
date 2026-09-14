//
//  Untitled.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import Foundation
import CoreData
import Combine

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [TransactionEntity] = []
    @Published var selectedCategory: String = "all"
    @Published var errorMessage: String?
    
    let categories = ["all", "food", "transport", "entertainment", "bills", "other"]
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTransactions()
    }
    
    var filteredTransactions: [TransactionEntity] {
        if selectedCategory == "all" {
            return transactions
        }
        return transactions.filter { $0.category == selectedCategory }
    }
    
    var totalAmount: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func fetchTransactions() {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            transactions = try viewContext.fetch(request)
        } catch {
            errorMessage = "Couldn't load transactions. Please try again."
        }
    }
    
    func deleteTransactions(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredTransactions[$0] }
        itemsToDelete.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
            fetchTransactions()
        } catch {
            errorMessage = "Couldn't delete transactions. Please try again."
        }
    }
}
