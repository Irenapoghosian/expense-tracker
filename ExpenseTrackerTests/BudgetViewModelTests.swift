//
//  BudgetViewModelTests.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import XCTest
import CoreData
@testable import ExpenseTracker

final class BudgetViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var repository: TransactionRepository!
    var sut: BudgetViewModel!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        repository = CoreDataTransactionRepository(context: context)
        sut = BudgetViewModel(repository: repository)
    }
    
    override func tearDown() {
        context = nil
        repository = nil
        sut = nil
        super.tearDown()
    }
    
    private func makeTransaction(title: String, amount: Double, category: String) {
        let t = repository.makeNewTransaction()
        t.id = UUID()
        t.title = title
        t.amount = amount
        t.category = category
        t.date = Date()
        try? repository.save(t)
    }
    
    func test_setBudget_failsWhenLimitIsZeroOrNegative() {
        sut.setBudget(category: "food", limit: 0)
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.budgetStatuses.isEmpty)
    }
    
    func test_setBudget_createsNewBudgetStatus() {
        sut.setBudget(category: "food", limit: 100)
        
        XCTAssertEqual(sut.budgetStatuses.count, 1)
        XCTAssertEqual(sut.budgetStatuses.first?.category, "food")
        XCTAssertEqual(sut.budgetStatuses.first?.limit, 100)

    }
    
    func test_budgetStatus_calculatesSpentFromTransactions() {
        makeTransaction(title: "Coffee", amount: 20, category: "food")
        makeTransaction(title: "Lunch", amount: 30, category: "food")
        
        sut.setBudget(category: "food", limit: 100)
        
        let status = sut.budgetStatuses.first
        XCTAssertEqual(status?.spent, 50)
        XCTAssertEqual(status?.remaining, 50)
        XCTAssertFalse(status?.isOverBudget ?? true)
    }
    
    func test_budgetStatus_detectsOverBudget() {
        makeTransaction(title: "Rent", amount: 150, category: "bills")
        
        sut.setBudget(category: "bills", limit: 100)
        
        let status = sut.budgetStatuses.first
        XCTAssertTrue(status?.isOverBudget ?? false)
        XCTAssertEqual(status?.remaining, -50)
    }
    
    func test_setBudget_updatesExistingBudgetForSameCategory() {
        sut.setBudget(category: "food", limit: 100)
        sut.setBudget(category: "food", limit: 200)
        
        XCTAssertEqual(sut.budgetStatuses.count, 1)
        XCTAssertEqual(sut.budgetStatuses.first?.limit, 200)
    }
}


