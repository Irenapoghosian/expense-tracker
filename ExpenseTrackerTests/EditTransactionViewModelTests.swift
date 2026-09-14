//
//  EditTransactionViewModelTests.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import XCTest
import CoreData
@testable import ExpenseTracker


final class EditTransactionViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var repository: TransactionRepository!
    var transaction: TransactionEntity!
    var sut: EditTransactionViewModel!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        repository = CoreDataTransactionRepository(context: context)
        
        transaction = repository.makeNewTransaction()
        transaction.id = UUID()
        transaction.title = "Coffee"
        transaction.amount = 5
        transaction.category = "food"
        transaction.date = Date()
        try? repository.save(transaction)
        
        sut = EditTransactionViewModel(transaction: transaction, repository: repository)
    }
    
    override func tearDown() {
        context = nil
        repository = nil
        transaction = nil
        sut = nil
        super.tearDown()
    }
    
    func test_init_populatesFieldsFromTransaction() {
        XCTAssertEqual(sut.title, "Coffee")
        XCTAssertEqual(sut.amount, "5.0")
        XCTAssertEqual(sut.category, "food")
    }
    
    func test_isValid_falseWhenTitleIsEmpty() {
        sut.title = ""
        
        XCTAssertFalse(sut.isValid)
    }
    
    func test_save_updatesTransactionWhenValid() {
        sut.title = "Lunch"
        sut.amount = "12"
        sut.category = "food"
        
        let result = sut.save()
        
        XCTAssertTrue(result)
        XCTAssertEqual(transaction.title, "Lunch")
        XCTAssertEqual(transaction.amount, 12)
    }
    
    func test_save_returnsFalseWhenInvalid() {
        sut.title = ""
        
        let result = sut.save()
        
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }
}
