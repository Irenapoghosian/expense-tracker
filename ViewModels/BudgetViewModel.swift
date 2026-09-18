//
//  BudgetViewModel.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//

import Foundation
import Combine

struct BudgetStatus: Identifiable {
    let id = UUID()
    let category: String
    let limit: Double
    let spent: Double
    
    var remaining: Double {
        limit - spent
    }
    
    var percentUsed: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
    
    var isOverBudget: Bool {
        spent > limit
    }
}

final class BudgetViewModel: ObservableObject {
    @Published var budgetStatuses: [BudgetStatus] = []
    @Published var errorMessage: String?
    
    private let repository: TransactionRepository
    
    let categories = ["food", "transport", "entertainment", "bills", "other"]
    
    init(repository: TransactionRepository) {
        self.repository = repository
        loadBudgets()
    }
    
    func loadBudgets() {
        do {
            let budgets = try repository.fetchBudgets()
            let transactions = try repository.fetchAll()
            
            budgetStatuses = budgets.map { budget in
                let category = budget.category ?? "other"
                let spent = transactions
                    .filter { $0.category == category }
                    .reduce(0) { $0 + $1.amount }
                
                return BudgetStatus(category: category, limit: budget.limit, spent: spent)
            }.sorted { $0.category < $1.category }
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.persistence(error).errorDescription
        }
    }
    
    func setBudget(category: String, limit: Double) {
        guard limit > 0 else {
            errorMessage = AppError.invalidInput("Budget must be greater than 0.").errorDescription
            return
        }
        
        do {
            try repository.saveBudget(category: category, limit: limit)
            loadBudgets()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.persistence(error).errorDescription
        }
    }
}
