//
//  CategoryBreakdownViewModelTests.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import XCTest
import CoreData
@testable import ExpenseTracker


final class CategoryBreakdownViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var repository: TransactionRepository!
    var sut: CategoryBreakdownViewModel!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        repository = CoreDataTransactionRepository(context: context)
        sut = CategoryBreakdownViewModel(repository: repository)
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
    
    func test_loadBreakdown_emptyWhenNoTransactions() {
        sut.loadBreakdown()
        
        XCTAssertTrue(sut.breakdown.isEmpty)
    }
    
    func test_loadBreakdown_groupsAndSumsByCategory() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Lunch", amount: 10, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        
        sut.loadBreakdown()
        
        XCTAssertEqual(sut.breakdown.count, 2)
        
        let food = sut.breakdown.first { $0.category == "food" }
        let transport = sut.breakdown.first { $0.category == "transport" }
        
        XCTAssertEqual(food?.amount, 15)
        XCTAssertEqual(transport?.amount, 2)
    }
    
    func test_loadBreakdown_sortedByAmountDescending() {
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Rent", amount: 100, category: "bills")
        
        sut.loadBreakdown()
        
        XCTAssertEqual(sut.breakdown.map { $0.category }, ["bills", "food", "transport"])
    }
}
