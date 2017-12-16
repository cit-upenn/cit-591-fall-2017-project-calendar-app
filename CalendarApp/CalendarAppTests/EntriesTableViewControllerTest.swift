//
//  EntriesTableViewControllerTest.swift
//  CalendarAppTests
//
//  Created by Jiaying Wang on 12/16/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import XCTest
import CoreData
@testable import CalendarApp

class EntriesTableViewControllerTest: XCTestCase {
    
    var entriesViewController: EntriesTableViewController!
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        entriesViewController = storyboard.instantiateViewController(withIdentifier: "EntriesTableViewController") as! EntriesTableViewController
       
    }
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
        entriesViewController = nil
    }
    
    func testViewLoad() {
        XCTAssertNotNil(entriesViewController, "View is not initialized properly")
    }
    
    func testTableViewLoad() {
        XCTAssertNotNil(entriesViewController.tableView, "TableView is not initialized properly")
    }
    
    // Test the number of rows in the table view is equal to the number of entries in core data
    func testNumberOfRow() {
        entriesViewController.fetchEntries()
        let rows = entriesViewController.tableView.numberOfRows(inSection: 0)
        let numOfEntries = entriesViewController.entries.count

        XCTAssertEqual(rows, numOfEntries)
    }
    
    func testTitleContent(){
        entriesViewController.fetchEntries()
        let title = entriesViewController.tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.textLabel?.text
        let text = entriesViewController.entries.reversed()[0].bodyText
        XCTAssertEqual(title, text)
    }
    
}
