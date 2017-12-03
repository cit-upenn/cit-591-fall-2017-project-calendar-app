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

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let monthColor = UIColor.darkGray
    let selectedMonthColor = UIColor.black
    let formatter = DateFormatter()
    let todaysDate = Date()
    var selectedDate = Date()
    var selectedRow: Int!
    
    //Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entries: [Entry] = []
    var todayJournal: [Entry] = []
//    var todayToDo: [ToDo] = []
    
    // TODO: change to fetch event from coredata
    var eventsFromServer: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setupCalendarView()
        self.navigationController?.navigationBar.isHidden = true
        calendarView.scrollToDate(todaysDate)
        calendarView.selectDates([todaysDate])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupCalendarView(){
        //setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //setup labels
        calendarView.visibleDates { (monthDates) in
            self.setupViewsOfCalendar(from: monthDates)
        }
        
    }
    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        
        formatter.dateFormat = "yyyy MM dd"
        if cellState.isSelected {
            cell.dateLabel.textColor = selectedMonthColor
        } else {
            cell.dateLabel.textColor = monthColor
        }
    }
    
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
//    func handleCellEvent(view: JTAppleCell?, cellState: CellState) {
//        guard let cell = view as? CalendarCell else {return}
//        cell.eventDotView.isHidden = !eventsFromServer.keys.contains(formatter.string(from: cellState.date))
//    }
    
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

extension CalendarViewController: JTAppleCalendarViewDataSource{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        //handleCellEvent(view: cell, cellState: cellState)
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "1900 01 01")!
        let endDate = formatter.date(from: "2500 12 31")!
        
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    //display the cell
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
        //handleCellEvent(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        //handleCellEvent(view: cell, cellState: cellState)
        selectedDate = date
        self.fetchData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        //handleCellEvent(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

extension CalendarViewController{
    func getServerEvents() -> [Date:String] {
        formatter.dateFormat = "yyyy MM dd"
        return [
            formatter.date(from: "2017 03 12")!: "Happy Birthday!",
            formatter.date(from: "2017 01 26")!: "Last day to drop class!",
            formatter.date(from: "2017 03 18")!: "Spring break!",
            formatter.date(from: "2017 07 23")!: "pay off credit card!",
            formatter.date(from: "2017 08 10")!: "new movie!!",
            formatter.date(from: "2017 11 01")!: "math midterm!",
            formatter.date(from: "2017 12 24")!: "Merry Christmas!",
        ]
    }
}

extension UIColor {
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
    //TODO: add todo data
    func fetchData() {
        //setup predicate
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateFrom = calendar.startOfDay(for: selectedDate)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
        let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [dateFrom, dateTo])
        
        //fetch data using predicate
        do {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = datePredicate
            todayJournal = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch entries: \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayJournal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.textLabel?.text = todayJournal.reversed()[indexPath.row].bodyText
        cell.detailTextLabel?.text = "Journal"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        performSegue(withIdentifier: "updateJournalFromCalendar", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateJournalFromCalendar" {
            let update = segue.destination as! UpdateJournalViewController
            update.entry = todayJournal.reversed()[selectedRow!]
        }
    }
}

