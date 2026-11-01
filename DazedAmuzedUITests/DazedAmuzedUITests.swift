//
//  DazedAmuzedUITests.swift
//  DazedAmuzedUITests
//
//  Created by Peyton Sadler on 2/11/26.
//

import XCTest

final class DazedAmuzedUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testCoronationFlowScratch() throws {
        let app = XCUIApplication()
        app.launch()

        let playTogether = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Play together")).firstMatch
        XCTAssertTrue(playTogether.waitForExistence(timeout: 5))
        playTogether.tap()

        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        for name in ["Dani", "Kat", "Mo"] {
            nameField.tap()
            nameField.typeText(name)
            app.buttons["Add player"].tap()
        }

        // Quick game: first to 5 points.
        let quick = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Quick")).firstMatch
        if quick.waitForExistence(timeout: 3) { quick.tap() }

        let letsPlay = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Let's play")).firstMatch
        XCTAssertTrue(letsPlay.waitForExistence(timeout: 5))
        letsPlay.tap()

        for round in 0..<8 {
            // Stop once we've landed on the Coronation screen.
            if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "GAME OVER")).firstMatch.waitForExistence(timeout: 1) {
                break
            }

            let tile = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Debate")).firstMatch
            if tile.waitForExistence(timeout: 5) { tile.tap() }
            Thread.sleep(forTimeInterval: 0.9)

            let pickWinnerBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Pick a winner")).firstMatch
            if pickWinnerBtn.waitForExistence(timeout: 5) { pickWinnerBtn.tap() }
            Thread.sleep(forTimeInterval: 0.4)

            // Always crown the same player so they reach the target score quickly.
            let daniRow = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Dani")).firstMatch
            if daniRow.waitForExistence(timeout: 3) { daniRow.tap() }
            Thread.sleep(forTimeInterval: 0.5)

            let nextRound = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Next round")).firstMatch
            if nextRound.waitForExistence(timeout: 3) {
                nextRound.tap()
            }
            Thread.sleep(forTimeInterval: 0.5)

            let letsGo = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Let's go")).firstMatch
            if letsGo.waitForExistence(timeout: 2) {
                letsGo.tap()
            }
            Thread.sleep(forTimeInterval: 0.5)
            print("completed round \(round)")
        }

        Thread.sleep(forTimeInterval: 1.0)
        try app.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/sim_shots/coronation.png"))

        let crownCardBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Crown Card")).firstMatch
        XCTAssertTrue(crownCardBtn.waitForExistence(timeout: 5))
        crownCardBtn.tap()

        Thread.sleep(forTimeInterval: 1.0)
        try app.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/sim_shots/crowncard.png"))

        let shareBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Share to story")).firstMatch
        XCTAssertTrue(shareBtn.waitForExistence(timeout: 3))
        shareBtn.tap()
        Thread.sleep(forTimeInterval: 1.2)
        try app.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "/tmp/sim_shots/sharesheet.png"))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
