//
//  ComposeViewController.swift
//  CalendarToDo
//
//  Created by Jiaying Wang on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//


import UIKit
import CoreData

// this class represents the controller of the add entry view
class AddEntryViewController: UIViewController, UITextViewDelegate 
{
    //MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // this method performs add if user taps on add
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
    
    // this method tells the delegate that editing of the specified text view has begun.
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }

    //This method is called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        
        setupNavBar()
    }
    
    // this method sets up the navigation bar 
    func setupNavBar() {
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "New Entry"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }

}
