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

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todo: Todo!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: .UIKeyboardWillShow,
            object: nil)
        
        textView.becomeFirstResponder()
        
        if let todo = todo {
            textView.text = todo.title
            textView.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priority)
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
        }
        do {
            try managedContext.save()
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
            request.returnsObjectsAsFaults = false
            do {
                let result = try managedContext.fetch(request)
                for data in result as! [NSManagedObject] {
                    print(data)
                }
            } catch {
                print("Failed")
            }
            
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)" )
        }
        
    }
}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
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

