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
    
    //MARK: - Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var calendarTableView: UITableView!
    
    //MARK: - Properties
    let monthColor = UIColor.darkGray
    let selectedMonthColor = UIColor.black
    let formatter = DateFormatter()
    let todaysDate = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
        calendarView.scrollToDate(todaysDate, animateScroll: false)
        //calendarView.scrollToDate(todaysDate)
        calendarView.selectDates([todaysDate])
        
    }
    
    //MARK: - Actions
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
    
    func handleCellEvent(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else {return}
        formatter.dateFormat = "yyyy MM dd"
        let cellDateString = formatter.string(from: cellState.date)
        let eventsFromCoreData = getCoreDataEvents()
        let contains = eventsFromCoreData.contains { (element) -> Bool in
            if let todo = element as? Todo {
                if todo.dueDate == nil {return false}
                var elementdateString = formatter.string(from: todo.dueDate!)
                if elementdateString == cellDateString {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
        cell.eventDot.isHidden = !contains
    }
    
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
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
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
        handleCellEvent(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard (cell as? CalendarCell) != nil else {return}
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvent(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

//MARK: - fetch data
extension CalendarViewController{
    func getCoreDataEvents() -> [AnyObject] {
        var entries = [AnyObject]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                entries.append(data)
            }
        } catch {
            print("Fetch data Failed \(error)")
        }
        return entries
//        formatter.dateFormat = "yyyy MM dd"
//        return [
//            "2017 03 12": "Happy Birthday!",
//            formatter.date(from: "2017 01 26")!: "Last day to drop class!",
//            formatter.date(from: "2017 03 18")!: "Spring break!",
//            formatter.date(from: "2017 07 23")!: "pay off credit card!",
//            formatter.date(from: "2017 08 10")!: "new movie!!",
//            "2017 11 01": "math midterm!",
//            formatter.date(from: "2017 12 24")!: "Merry Christmas!",
//       ]
    }
}

// MARK: - UIColor
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


