//
//  ProfileManagerTests.swift
//  ExpenseTrackerTests
//

import XCTest
@testable import ExpenseTracker

final class ProfileManagerTests: XCTestCase {
    private var profileManager: ProfileManager!
    private var username: String!

    override func setUp() {
        super.setUp()
        profileManager = ProfileManager()
        username = "profile_test_\(UUID().uuidString.prefix(8))"
    }

    override func tearDown() {
        profileManager.deleteAllData(for: username)
        profileManager = nil
        super.tearDown()
    }

    func testLoadWithNoSavedDataReturnsEmptyProfile() {
        profileManager.load(for: username)
        XCTAssertEqual(profileManager.firstName, "")
        XCTAssertEqual(profileManager.lastName, "")
        XCTAssertEqual(profileManager.email, "")
        XCTAssertNil(profileManager.birthday)
        XCTAssertNil(profileManager.profileImage)
    }

    func testSaveAndReloadPersistsProfileData() {
        profileManager.load(for: username)
        let birthday = Date(timeIntervalSince1970: 0)
        profileManager.save(firstName: "Irena", lastName: "Poghosyan", email: "irena@example.com", birthday: birthday, image: nil)

        XCTAssertEqual(profileManager.firstName, "Irena")
        XCTAssertEqual(profileManager.fullName, "Irena Poghosyan")
        XCTAssertEqual(profileManager.email, "irena@example.com")
        XCTAssertEqual(profileManager.birthday, birthday)

        let reloaded = ProfileManager()
        reloaded.load(for: username)
        XCTAssertEqual(reloaded.firstName, "Irena")
        XCTAssertEqual(reloaded.lastName, "Poghosyan")
        XCTAssertEqual(reloaded.email, "irena@example.com")
        XCTAssertEqual(reloaded.birthday, birthday)
    }

    func testClearResetsPublishedProperties() {
        profileManager.load(for: username)
        profileManager.save(firstName: "Irena", lastName: "Poghosyan", email: "irena@example.com", birthday: Date(), image: nil)

        profileManager.clear()

        XCTAssertEqual(profileManager.firstName, "")
        XCTAssertEqual(profileManager.lastName, "")
        XCTAssertEqual(profileManager.email, "")
        XCTAssertNil(profileManager.birthday)
        XCTAssertNil(profileManager.profileImage)
    }

    func testDeleteAllDataRemovesSavedProfile() {
        profileManager.load(for: username)
        profileManager.save(firstName: "Irena", lastName: "Poghosyan", email: "irena@example.com", birthday: Date(), image: nil)

        profileManager.deleteAllData(for: username)

        let reloaded = ProfileManager()
        reloaded.load(for: username)
        XCTAssertEqual(reloaded.firstName, "")
        XCTAssertEqual(reloaded.email, "")
    }

    func testFullNameTrimsWhitespaceWhenOnlyFirstNameProvided() {
        profileManager.load(for: username)
        profileManager.save(firstName: "Irena", lastName: "", email: "", birthday: nil, image: nil)
        XCTAssertEqual(profileManager.fullName, "Irena")
    }
}
