//
//  TransactionRepository.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//


import Foundation
import CoreData

protocol TransactionRepository {
    func fetchAll() throws -> [TransactionEntity]
    func save(_ transaction: TransactionEntity) throws
    func delete(_ transaction: TransactionEntity) throws
    func makeNewTransaction() -> TransactionEntity
    
    func fetchBudgets() throws -> [BudgetEntity]
    func saveBudget(category: String, limit: Double) throws
    func deleteBudget(_ budget: BudgetEntity) throws
}

final class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll() throws -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        return try context.fetch(request)
    }
    
    
    func save(_ transaction: TransactionEntity) throws {
        try context.save()
    }
    
    func delete(_ transaction: TransactionEntity) throws {
        context.delete(transaction)
        try context.save()
    }
    
    func makeNewTransaction() -> TransactionEntity {
        TransactionEntity(context: context)
    }
    
    func fetchBudgets() throws -> [BudgetEntity] {
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        return try context.fetch(request)
    }
    
    func saveBudget(category: String, limit: Double) throws {
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        let existing = try context.fetch(request).first
        
        let budget = existing ?? BudgetEntity(context: context)
        budget.category = category
        budget.limit = limit
        
        try context.save()
    }
    
    func deleteBudget(_ budget: BudgetEntity) throws {
        context.delete(budget)
        try context.save()
    }
}
