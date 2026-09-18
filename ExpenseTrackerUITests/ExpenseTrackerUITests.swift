import XCTest

final class ExpenseTrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)
        return app
    }

    private func dismissOnboardingIfPresent(_ app: XCUIApplication) {
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        }
    }

    func testAddTransaction_appearsInList() {
        let app = launchApp()

        app.tabBars.buttons["Expenses"].tap()
        app.buttons["Add Transaction"].tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("UI Test Coffee")

        let amountField = app.textFields["Amount"]
        amountField.tap()
        amountField.typeText("4.50")

        app.buttons["Save"].tap()

        let newRow = app.staticTexts["UI Test Coffee"]
        XCTAssertTrue(newRow.waitForExistence(timeout: 3), "The newly added transaction should appear in the list")
    }

    func testAddTransaction_saveDisabledWithoutTitle() {
        let app = launchApp()

        app.tabBars.buttons["Expenses"].tap()
        app.buttons["Add Transaction"].tap()

        let amountField = app.textFields["Amount"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 3))
        amountField.tap()
        amountField.typeText("10")
        
        // Title left empty -> Save must stay disabled.
        XCTAssertFalse(app.buttons["Save"].isEnabled)

        app.buttons["Cancel"].tap()
    }

    func testSetBudget_appearsInBudgetsList() {
        let app = launchApp()

        app.tabBars.buttons["Budgets"].tap()
        app.buttons["Set Budget"].tap()

        let limitField = app.textFields["Monthly limit"]
        XCTAssertTrue(limitField.waitForExistence(timeout: 3))
        limitField.tap()
        limitField.typeText("250")

        app.buttons["Save"].tap()
        
        // Default category picker selection is "food" -> displayed as "Food".
        let categoryLabel = app.staticTexts["Food"]
        XCTAssertTrue(categoryLabel.waitForExistence(timeout: 3), "The new budget's category should appear in the budgets list")
    }
}
