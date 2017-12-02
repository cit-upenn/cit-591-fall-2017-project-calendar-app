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
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func addClick(_ sender: UIBarButtonItem) {
        //Do not save the entry if nothing is typed by the user
        if !((textView.text.isEmpty) || textView?.text == "     Type anything here...") {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entry = Entry(context: context)
            entry.bodyText = textView.text!
            entry.createdAt = Date()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        
        setupNavBar()
    }
    
    func setupNavBar() {
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "New Entry"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }

}
