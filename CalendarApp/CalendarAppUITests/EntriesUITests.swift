//
//  EntriesUITests.swift
//  CalendarAppUITests
//
//  Created by Jiaying Wang on 12/16/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import XCTest
@testable import CalendarApp

class EntriesUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launchArguments = ["--Reset"]
        app.launch()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakingtoAddEntryView(){
        app.tabBars.buttons["Journal"].tap()
        XCTAssert(app.navigationBars["Journal"].exists, "Journal view should pop")
        
    }
    
    func testAddEntry() {
        app.tabBars.buttons["Journal"].tap()
        app.navigationBars["Journal"].buttons["Add"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("TEST ADD")
        app.navigationBars["New Entry"].buttons["Add"].tap()
        XCTAssert(app.tables.cells.staticTexts["TEST ADD"].exists, "A entry with title \"TEST ADD\" should appear")
    }
    
    func testUpdateEntry() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Journal"].tap()
        app.tables.cells.staticTexts["TEST ADD"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("UPDATE ")
        app.navigationBars["Journal"].buttons["Save"].tap()
        
        XCTAssert(app.tables.cells.staticTexts["UPDATE TEST ADD"].exists, "The entry with title \"UPDATE TEST UPDATE\" should appear")
    }
    
    
}

