//
//  CalendarViewController.swift
//  CalendarApp
//
//  Created by Olivia Sun on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData

// this class represents the controller of the calenda view
class CalendarViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var calendarTableView: UITableView!

    
    //MARK: - Properties
    let monthColor = UIColor.darkGray
    let selectedMonthColor = UIColor.black
    let formatter = DateFormatter()
    let todaysDate = Date()
    var selectedDate = Date()
    var selectedRow: Int!
    
    //MARK: - Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entries: [Entry] = []
    var todayData: [AnyObject] = []
    
    //This method is called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchData()
        setupCalendarView()
        
        self.navigationController?.navigationBar.isHidden = true
        calendarView.scrollToDate(todaysDate, animateScroll: false)
        calendarView.selectDates([todaysDate])
        
    }
    
    // this method notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
        self.navigationController?.navigationBar.isHidden = true
        calendarView.reloadData()
    }
    
   
    //MARK: - Actions

    // this method setup calendar spacing and labels
    func setupCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (monthDates) in
            self.setupViewsOfCalendar(from: monthDates)
        }
        
    }
    
    // this method handels the text color of each cell
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        if cellState.isSelected {
            cell.dateLabel.textColor = selectedMonthColor
        } else {
            cell.dateLabel.textColor = monthColor
        }
    }
    
    // this method handels the cell that is been selected
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    // this method decides whether to show the event dot on certain cell
    func handleCellEvent(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        formatter.dateFormat = "yyyy MM dd"
        let cellDateString = formatter.string(from: cellState.date)
        let eventsFromCoreData = getCoreDataEvents()
        let containsTodo = eventsFromCoreData.contains { (element) -> Bool in
            if let todo = element as? Todo {
                if todo.dueDate == nil {return false}
                let elementdateString = formatter.string(from: todo.dueDate!)
                if elementdateString == cellDateString {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        let containsJournal = eventsFromCoreData.contains { (element) -> Bool in
            if let journal = element as? Entry {
                let elementdateString = formatter.string(from: journal.createdAt!)
                if elementdateString == cellDateString {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        cell.eventDot.isHidden = !(containsTodo || containsJournal)
    }
    
    // this method sets up the calendar and displays the year&month headers
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - calendar view data source
extension CalendarViewController: JTAppleCalendarViewDataSource{
    // this method configures each calendar cell
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
    // this method asks the data source to return the start and end boundary dates as well as the calendar to use.
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "1999 01 01")!
        let endDate = formatter.date(from: "2200 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return parameters
    }
}


// MARK: - calendar view delegate
extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    //this method tells the delegate that the JTAppleCalendar is about to display a date-cell.
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        if cellState.dateBelongsTo == .previousMonthWithinBoundary{
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
        return cell
    }
    
    // this method tells the delegate that the JTAppleCalendar is about to display a date-cell.
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        selectedDate = date
        self.fetchData()
        handleCellEvent(cell: cell, cellState: cellState)

    }
    
    // this method tells the delegate that a date-cell with a specified date was de-selected
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
    // this method tells the delegate that the calendar view scrolled to a segment beginning and ending with a particular date
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

//MARK: - fetch data
extension CalendarViewController{
    // this method fetchs entries from core data and returns all the entries stored
    func getCoreDataEvents() -> [AnyObject] {
        var entries = [AnyObject]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        request.returnsObjectsAsFaults = false
        request2.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                entries.append(data)
            }
            let result2 = try context.fetch(request2)
            for data in result2 as! [NSManagedObject] {
                entries.append(data)
            }
        } catch {
            print("Fetch data Failed \(error)")
        }
        return entries
    }
}

// MARK: - UIColor
extension UIColor {
    // this method allows to set color by given hex value 
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0) {
        self.init (
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate{
    
    // MARK: - Table view data source
    // this function fetches data from CoreDate stack.
    func fetchData() {
        //setup predicate
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateFrom = calendar.startOfDay(for: selectedDate)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
        let entryDatePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [dateFrom, dateTo])
        let todoDatePredicate = NSPredicate(format: "(%@ <= dueDate) AND (dueDate < %@)", argumentArray: [dateFrom, dateTo])
        //fetch data using predicate
        do {
            let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            let todoFetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            entryFetchRequest.predicate = entryDatePredicate
            todoFetchRequest.predicate = todoDatePredicate
            todayData = try context.fetch(entryFetchRequest)
            let results = try context.fetch(todoFetchRequest)
            for result in results {
                todayData.append(result)
            }
        } catch let error as NSError {
            print("Could not fetch entries: \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    //this method asks the data source to return the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // this method tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayData.count
    }
    
    // this method asks coredata stack for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let data = todayData.reversed()[indexPath.row]
        cell.textLabel?.textColor = UIColor.black
        if let journal = data as? Entry {
            cell.textLabel?.text = journal.bodyText
            cell.detailTextLabel?.text = "Journal"
        } else if let todo = data as? Todo {
            if todo.complete {
                cell.textLabel?.text = "Completed: \(todo.title!)"
                cell.textLabel?.textColor = UIColor.gray
            } else {
                cell.textLabel?.text = todo.title
            }
            cell.detailTextLabel?.text = "Todo"
        }
        cell.detailTextLabel?.textColor = UIColor.init(colorWithHexValue: 0x242794)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        let data = todayData.reversed()[selectedRow]
        if data is Entry {
            performSegue(withIdentifier: "updateJournalFromCalendar", sender: self)
        } else if let todo = data as? Todo {
            if !todo.complete {
            performSegue(withIdentifier: "updateTodoFromCalendar", sender: self)
            } else {
                return
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // this method asks the delegate for the actions to display in response to a swipe in the specified row
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            let data = self.todayData.reversed()[indexPath.row]
            if let journal = data as? Entry {
                self.context.delete(journal)
            } else if let todo = data as? Todo {
                self.context.delete(todo)
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.fetchData()
        }
        let check = UITableViewRowAction(style: .default, title: "Check") { (action, indexPath) in
            
            let data = self.todayData.reversed()[indexPath.row]
            if let todo = data as? Todo {
                todo.complete = true
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.fetchData()
        }
        check.backgroundColor = UIColor.init(colorWithHexValue: 0xffb735)
        delete.backgroundColor = UIColor(red: 36/255, green: 39/255, blue: 148/255, alpha: 1.0)
        let data = self.todayData.reversed()[indexPath.row]
        if data is Entry {
            return [delete]
        } else if let todo = data as? Todo {
            if !todo.complete {
                return [check, delete]
            } else {
                return [delete]
            }
        }
        return [delete]
    }
    
    //this method notifies the view controller that the storyboard is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateJournalFromCalendar" {
            let update = segue.destination as! UpdateJournalViewController
            let data = todayData.reversed()[selectedRow!]
            if let journal = data as? Entry {
                update.entry = journal
            }
        } else if segue.identifier == "updateTodoFromCalendar" {
            let update = segue.destination as! AddTodoViewController
            update.managedContext = self.context
            let data = todayData.reversed()[selectedRow!]
            if let todo = data as? Todo {
                update.todo = todo
            }
        }
    }
}

