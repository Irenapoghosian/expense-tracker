//
//  AddTransactionViewModelTests.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 14.09.26.
//


import XCTest
import CoreData
@testable import ExpenseTracker

final class AddTransactionViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var repository: TransactionRepository!
    var sut: AddTransactionViewModel!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        repository = CoreDataTransactionRepository(context: context)
        sut = AddTransactionViewModel(repository: repository)
    }
    
    override func tearDown() {
        context = nil
        repository = nil
        sut = nil
        super.tearDown()
    }
    
    func test_isValid_falseWhenTitleIsEmpty() {
        sut.title = ""
        sut.amount = "10"
        
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_falseWhenAmountIsInvalid() {
        sut.title = "Coffee"
        sut.amount = "abc"
        
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_falseWhenAmountIsZeroOrNegative() {
        sut.title = "Coffee"
        sut.amount = "0"
        
        XCTAssertFalse(sut.isValid)
    }
    
    func test_isValid_trueWhenTitleAndAmountAreValid() {
        sut.title = "Coffee"
        sut.amount = "5"
        
        XCTAssertTrue(sut.isValid)
    }
    
    func test_save_returnsFalseWhenInvalid() {
        sut.title = ""
        sut.amount = "5"
        
        let result = sut.save()
        
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func test_save_returnsTrueAndPersistsWhenValid() {
        sut.title = "Coffee"
        sut.amount = "5"
        sut.category = "food"
        
        let result = sut.save()
        
        XCTAssertTrue(result)
        
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let saved = try? context.fetch(request)
        XCTAssertEqual(saved?.count, 1)
        XCTAssertEqual(saved?.first?.title, "Coffee")
    }
}
