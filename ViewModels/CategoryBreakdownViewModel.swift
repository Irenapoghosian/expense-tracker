//
//  CategoryBreakdownViewModel.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import Foundation
import Combine


struct CategoryAmount: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

final class CategoryBreakdownViewModel: ObservableObject {
    @Published var breakdown: [CategoryAmount] = []
    
    private let repository: TransactionRepository
    
    init(repository: TransactionRepository) {
        self.repository = repository
        loadBreakdown()
    }
    
    func loadBreakdown() {
        guard let transactions = try? repository.fetchAll() else {
            breakdown = []
            return
        }
        
        let grouped = Dictionary(grouping: transactions) { $0.category ?? "other" }
        breakdown = grouped.map { category, items in
            CategoryAmount(category: category, amount: items.reduce(0) { $0 + $1.amount })
        }.sorted { $0.amount > $1.amount }
    }
}
