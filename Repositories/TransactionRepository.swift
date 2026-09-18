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
        do {
            return try context.fetch(request)
        } catch {
            throw AppError.persistence(error)
        }
    }
    
    func save(_ transaction: TransactionEntity) throws {
        do {
            try context.save()
        } catch {
            throw AppError.persistence(error)
        }
    }
    
    func delete(_ transaction: TransactionEntity) throws {
        context.delete(transaction)
        do {
            try context.save()
        } catch {
            throw AppError.persistence(error)
        }
    }
    
    func makeNewTransaction() -> TransactionEntity {
        TransactionEntity(context: context)
    }
    
    func fetchBudgets() throws -> [BudgetEntity] {
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            throw AppError.persistence(error)
        }
    }
    
    func saveBudget(category: String, limit: Double) throws {
        guard limit > 0 else {
            throw AppError.invalidInput("Budget must be greater than 0.")
        }
        
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let existing = try context.fetch(request).first
            let budget = existing ?? BudgetEntity(context: context)
            budget.category = category
            budget.limit = limit
            try context.save()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistence(error)
        }
    }
    
    func deleteBudget(_ budget: BudgetEntity) throws {
        context.delete(budget)
        do {
            try context.save()
        } catch {
            throw AppError.persistence(error)
        }
    }
}
