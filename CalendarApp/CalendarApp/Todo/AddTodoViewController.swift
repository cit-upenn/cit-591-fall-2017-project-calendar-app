//
//  AddTodoViewController.swift
//  CalendarApp
//
//  Created by Olivia Sun on 11/30/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

// this class represents the controller of the addtodoview 
class AddTodoViewController: UIViewController {

    //MARK: - Outlets
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setDueButton: UIButton!
    @IBOutlet weak var setReminderButton: UIButton!
    @IBOutlet weak var dateSelector: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bottomButtons: UIStackView!
    
    //MARK: - Properties
    var managedContext: NSManagedObjectContext!
        //= (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todo: Todo?
    let dateFormatter = DateFormatter()
    var dueDateFromPicker:Date? = nil
    var reminderDateFromPicker:Date? = nil
    var typeDatePicked = ""
    
    
    // This method is called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //the view controller observes whether the keyboard shows
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: .UIKeyboardWillShow,
            object: nil)
        
        if let todo = self.todo {
            //showing what's there already
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            
            textView.text = todo.title
            textView.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priority)
            if (todo.dueDate != nil){
                let dueDate = dateFormatter.string(from: todo.dueDate!)
                setDueButton.setTitle("Due Date: \(dueDate)", for: UIControlState.normal)
            }
            if (todo.reminderDate != nil){
                let remindDate = dateFormatter.string(from: todo.reminderDate!)
                setReminderButton.setTitle("Reminder Date: \(remindDate)", for: UIControlState.normal)
            }
        }
    }
    
    //MARK: Actions
    
    // this method is called when the keyboard is about to show
    @objc func keyboardWillShow(with notification: Notification){
        let key = "UIKeyboardFrameEndUserInfoKey"
        
        guard let keyboardFrame = notification.userInfo? [key] as? NSValue else {return}
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomConstraint.constant = keyboardHeight + 16
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // this function dismiss and resigns the keyboard
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    // cancel button
    @IBAction func cancel(_ sender: UIButton) {
        dismissAndResign()
    }
    
    // done button
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {return}
        if let todo = self.todo {
            todo.title = title
            todo.priority = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let todo = Todo(context: managedContext)
            todo.title = title
            todo.priority = Int16(segmentedControl.selectedSegmentIndex)
            todo.setupDate = Date()
            self.todo = todo
        }
        if (dueDateFromPicker != nil) {
            self.todo?.dueDate = dueDateFromPicker
        }
        if (reminderDateFromPicker != nil) {
            self.todo?.reminderDate = reminderDateFromPicker
        }
        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)" )
        }
        
        //set up push notification for reminder
        if self.todo?.reminderDate != nil {
            let content = UNMutableNotificationContent()
            content.title = "Don't forget"
            content.body = (self.todo?.title)!
            content.sound = UNNotificationSound.default()
            
            let date = self.todo?.reminderDate
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date!)
            triggerDate.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                        repeats: false)
            let identifier = "UYLLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        
    }
   
    
    // set due button
    @IBAction func setDueDate(_ sender:UIButton) {
        textView.resignFirstResponder()
        bottomButtons.isHidden = true
        dateSelector.isHidden = false
        typeDatePicked = "due"
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // set reminder button
    @IBAction func setReminderDate(_ sender: UIButton) {
        textView.resignFirstResponder()
        bottomButtons.isHidden = true
        dateSelector.isHidden = false
        typeDatePicked = "remind"
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //cancel button in date selector
    @IBAction func cancelSetDate(_ sender: UIBarButtonItem) {
        dismissDateSelector()
    }
    
    // done button in date selector
    @IBAction func doneSetDate(_ sender: UIBarButtonItem) {
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
        if typeDatePicked == "due"{
            setDueButton.setTitle("Due Date: \(strDate)", for: UIControlState.normal)
            dueDateFromPicker = datePicker.date
        } else {
            setReminderButton.setTitle("Reminder Date: \(strDate)", for: UIControlState.normal)
            reminderDateFromPicker = datePicker.date
        }
        dismissDateSelector()
    }
    
    // this method dismissed the date selector
    fileprivate func dismissDateSelector(){
        dateSelector.isHidden = true
        bottomButtons.isHidden = false
        //textView.becomeFirstResponder()
        bottomConstraint.constant = 16
    }
    
    
}


extension AddTodoViewController: UITextViewDelegate {
    
    // this method tells the delegate that editing of the specified text view has begun.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter your todo here..." {
            textView.text.removeAll()
        }
    }
    
    // this method tells the delegate that the text selection changed in the specified text view.
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.becomeFirstResponder()
        
        bottomButtons.isHidden = false
        if doneButton.isHidden{
            
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

