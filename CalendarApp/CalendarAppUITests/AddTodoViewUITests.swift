//
//  AddTodoViewUITests.swift
//  CalendarAppUITests
//
//  Created by Olivia Sun on 12/17/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import XCTest

class AddTodoViewUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoneButtonShowup() {
        app.tabBars.buttons["Todo"].tap()
        app.navigationBars["Todo"].buttons["Add"].tap()
        
        let doneButton = app.buttons.element(matching: .button, identifier: "doneButton")
        XCTAssertFalse(doneButton.exists)
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textView).element
        textView.tap()
        textView.typeText("1")
        XCTAssertTrue(doneButton.exists, "done button should show up ")
    }
    
}
