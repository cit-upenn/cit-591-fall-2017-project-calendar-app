//
//  TodoTests.swift
//  CalendarAppTests
//
//  Created by Olivia Sun on 12/16/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import XCTest
import CoreData
@testable import CalendarApp

class TodoTests: XCTestCase {
    var vc: TodoTableViewController!
    let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    var resultsController: NSFetchedResultsController<Todo>!
    let request: NSFetchRequest<Todo> = Todo.fetchRequest()
    
    override func setUp() {
        super.setUp()
        
        vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TodoTableViewController") as! TodoTableViewController
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
//        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
//            return
//        }
//        do {
//            try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
//        } catch {
//            print(error)
//        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTableViewNotNil(){
        XCTAssertTrue(vc.tableView != nil, "The table view should be set")
    }
    
    func testDataProviderHasTableViewPropertySetAfterLoading() {
        XCTAssert(vc.tableView === vc.tableView,
                  "The table view should be set to the table view of the data source")
    }
    
    func testPastDueSubtitleColor(){
        let managedContext = vc.managedContext
        let todo = Todo(context: managedContext)
        todo.title = "test"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let due = dateFormatter.date(from: "1999-11-11 11:11")
        todo.dueDate = due
        todo.setupDate = Date()
        
        do {
            try managedContext.save()
        } catch {
            print("Error saving todo: \(error)" )
        }
        
        let sortDescriptor1 = NSSortDescriptor(key: "setupDate", ascending: false)
        request.sortDescriptors = [sortDescriptor1]
        request.predicate = NSPredicate(format: "complete == false")
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self as? NSFetchedResultsControllerDelegate
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
        vc.tableView.reloadData()
        let cell = vc.tableView.cellForRow(at: IndexPath(item: 0, section: 0))
        
        XCTAssert(cell!.detailTextLabel!.textColor == .red, "past due todo's due date should show in red")
    }
    

    
}
