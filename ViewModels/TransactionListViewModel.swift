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
    
    private var repository: TransactionRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: TransactionRepository) {
        self.repository = repository
        fetchTransactions()
        observeRemoteChanges()
    }
    
    private func observeRemoteChanges() {
           NotificationCenter.default.publisher(for: .dataStoreDidChange)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] _ in
                   self?.fetchTransactions()
               }
               .store(in: &cancellables)
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
        do {
            transactions = try repository.fetchAll()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.persistence(error).errorDescription

        }
    }
    
    func deleteTransactions(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredTransactions[$0] }
        
        do {
            for item in itemsToDelete {
                try repository.delete(item)
            }
            fetchTransactions()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.persistence(error).errorDescription
        }
    }
}
