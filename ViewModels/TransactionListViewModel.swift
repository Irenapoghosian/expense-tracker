//
//  Untitled.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//

import Foundation
import CoreData
import Combine

enum TransactionSortOption: String, CaseIterable, Identifiable {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateDescending: return "Newest First"
        case .dateAscending: return "Oldest First"
        case .amountDescending: return "Amount: High to Low"
        case .amountAscending: return "Amount: Low to High"
        }
    }

    var icon: String {
        switch self {
        case .dateDescending, .dateAscending: return "calendar"
        case .amountDescending, .amountAscending: return "dollarsign.circle"
        }
    }
}

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [TransactionEntity] = []
    @Published var selectedCategory: String = "all"
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var sortOption: TransactionSortOption = .dateDescending
    
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
        var result = transactions

        if selectedCategory != "all" {
            result = result.filter { $0.category == selectedCategory }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            result = result.filter { transaction in
                (transaction.title ?? "").localizedCaseInsensitiveContains(trimmedSearch)
            }
        }

        return sorted(result)
    }

    private func sorted(_ items: [TransactionEntity]) -> [TransactionEntity] {
        switch sortOption {
        case .dateDescending:
            return items.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        case .dateAscending:
            return items.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        case .amountDescending:
            return items.sorted { $0.amount > $1.amount }
        case .amountAscending:
            return items.sorted { $0.amount < $1.amount }
        }
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
