//
//  ComposeViewController.swift
//  CalendarToDo
//
//  Created by Jiaying Wang on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//


import UIKit
import CoreData

class AddEntryViewController: UIViewController, UITextViewDelegate 
{
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addClick(_ sender: UIButton) {
        //Do not save the entry if nothing is typed by the user
        if !((textView.text.isEmpty) || textView?.text == "     Type anything here...") {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entry = Entry(context: context)
            entry.bodyText = textView.text!
            entry.createdAt = Date()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        dismiss(animated: true, completion: nil)
    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.text = ""
//        textView.textColor = UIColor.black
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        
        //move view according to keyboard appearance
        self.textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove Keyboard notification observer
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(with notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant -= keyboardSize.height
            UIView.animate(withDuration: 0, animations: {self.view.layoutIfNeeded()}, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(with notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant += keyboardSize.height
            UIView.animate(withDuration: 0, animations: {self.view.layoutIfNeeded()}, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
   
        if text.isEmpty {
            textView.text = "     Type anything here..."
            textView.textColor = UIColor.lightGray
            return false
        } else {
            if textView.text == "     Type anything here..." {
            textView.text = nil
            textView.textColor = UIColor.black
            }
        }
        
        return true
    }

}
