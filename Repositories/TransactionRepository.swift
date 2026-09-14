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
}

final class CoreDataTransactionRepository: TransactionRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchall() throws -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        return try context.fetch(request)
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
}
