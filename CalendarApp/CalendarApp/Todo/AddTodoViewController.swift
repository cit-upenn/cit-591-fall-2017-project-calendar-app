//
//  AddTodoViewController.swift
//  CalendarApp
//
//  Created by Olivia Sun on 11/30/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//

import UIKit
import CoreData

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
    var didUpdateDueDate = false
    var didUpdateReminderDate = false
    var typeDatePicked = "due"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @objc func keyboardWillShow(with notification: Notification){
        let key = "UIKeyboardFrameEndUserInfoKey"
        
        guard let keyboardFrame = notification.userInfo? [key] as? NSValue else {return}
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomConstraint.constant = keyboardHeight + 16
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }
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
        if didUpdateDueDate {
            self.todo?.dueDate = datePicker.date
        }
        if didUpdateReminderDate {
            self.todo?.reminderDate = datePicker.date
        }
        
        
        do {
            try managedContext.save()
            
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
//            request.returnsObjectsAsFaults = false
//            do {
//                let result = try managedContext.fetch(request)
//                for data in result as! [NSManagedObject] {
//                    print(data)
//                }
//            } catch {
//                print("Failed")
//            }
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)" )
        }
        
    }
    
    @IBAction func setDueDate(_ sender:UIButton) {
        textView.resignFirstResponder()
        bottomButtons.isHidden = true
        dateSelector.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func setReminderDate(_ sender: UIButton) {
        textView.resignFirstResponder()
        bottomButtons.isHidden = true
        dateSelector.isHidden = false
        typeDatePicked = "remind"
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func cancelSetDate(_ sender: UIBarButtonItem) {
        dismissDateSelector()
    }
    
    
    @IBAction func doneSetDate(_ sender: UIBarButtonItem) {
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
        if typeDatePicked == "due"{
            setDueButton.setTitle("Due Date: \(strDate)", for: UIControlState.normal)
            didUpdateDueDate = true
        } else {
            setReminderButton.setTitle("Reminder Date: \(strDate)", for: UIControlState.normal)
            didUpdateReminderDate = true
        }
        dismissDateSelector()
    }
    
    fileprivate func dismissDateSelector(){
        dateSelector.isHidden = true
        bottomButtons.isHidden = false
        textView.becomeFirstResponder()
    }
    
    
}


extension AddTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.becomeFirstResponder()
        bottomButtons.isHidden = false
        
        if doneButton.isHidden{
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

