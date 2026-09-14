//
//  ExpenseTrackerTests.swift
//  ExpenseTrackerTests
//
//  Created by Iren Poghosyan on 14.09.26.
//

import XCTest
import CoreData
@testable import ExpenseTracker

final class TransactionListViewModelTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var sut: TransactionListViewModel!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
        sut = TransactionListViewModel(context: context)
    }
    
    override func tearDown() {
        context = nil
        sut = nil
        super.tearDown()
    }
    
    private func makeTransaction(title: String, amount: Double, category: String) {
        let t = TransactionEntity(context: context)
        t.id = UUID()
        t.title = title
        t.amount = amount
        t.category = category
        t.date = Date()
        try? context.save()
    }
    
    func test_fetchTransactions_loadsAllTransactions() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        
        sut.fetchTransactions()
        
        XCTAssertEqual(sut.transactions.count, 2)
    }
    
    func test_filteredTransactions_returnsAllWhenCategoryIsAll() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        sut.fetchTransactions()

        sut.selectedCategory = "all"

        XCTAssertEqual(sut.filteredTransactions.count, 2)
    }
    
    func test_filteredTransactions_filtersByCategory() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        sut.fetchTransactions()

        sut.selectedCategory = "food"

        XCTAssertEqual(sut.filteredTransactions.count, 1)
        XCTAssertEqual(sut.filteredTransactions.first?.title, "Coffee")
    }
    
    func test_totalAmount_sumsFilteredTransactions() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Lunch", amount: 10, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        sut.fetchTransactions()

        sut.selectedCategory = "food"

        XCTAssertEqual(sut.totalAmount, 15)
    }
    
    func test_deleteTransactions_removesTransaction() {
        makeTransaction(title: "Coffee", amount: 5, category: "food")
        makeTransaction(title: "Bus", amount: 2, category: "transport")
        sut.fetchTransactions()

        let indexToDelete = IndexSet(integer: 0)
        sut.deleteTransactions(at: indexToDelete)

        XCTAssertEqual(sut.transactions.count, 1)
    }
}
