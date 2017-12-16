//
//  TodoUITests.swift
//  CalendarAppTests
//
//  Created by Olivia Sun on 12/16/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import XCTest
@testable import CalendarApp

class TodoUITests: XCTestCase {
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launchArguments = ["--Reset"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        //reset to original state
        
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testTakingtoTodoView() {
        app.tabBars.buttons["Todo"].tap()
        XCTAssert(app.navigationBars["Todo"].exists, "Todo tableview should pop")
    }
    
    func testTodoTitle(){
        app.tabBars.buttons["Todo"].tap()
        app.navigationBars["Todo"].buttons["Add"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textView).element
        textView.tap()
        textView.tap()
        textView.typeText("Test todo")
        app.buttons["Done"].tap()
        
        XCTAssert(app.tables.cells.staticTexts["Test todo"].exists, "A todo entry with title test todo should appear")
    }
    
    func testCellShowDueDate() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Todo"].tap()
        app.navigationBars["Todo"].buttons["Add"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textView).element
        textView.tap()
        textView.typeText("Test due")
        app.buttons["Set a due date"].tap()
        app.navigationBars["Select a date"].buttons["Done"].tap()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let due = dateFormatter.string(from: Date())
        app.buttons["Done"].tap()
        
        let cell = app.tables.cells.element
        XCTAssert(cell.staticTexts["Due date: \(due)"].exists, "A todo entry with title test todo should appear")    
    }
    
}
