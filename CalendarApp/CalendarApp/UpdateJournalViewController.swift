//
//  UpdateJournalViewController.swift
//  CalendarToDo
//
//  Created by Jiaying Wang on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//


import UIKit

class UpdateJournalViewController: UIViewController, UITextViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entry: Entry!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateField: UITextField!
    
    @IBAction func saveClick(_ sender: Any) {
        guard let updateText = textView.text else {
            return
        }
        entry.bodyText = updateText
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.textView.delegate = self
        displayExistedEntry()
        setupNavBar()
    }
    
    func setupNavBar() {
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Journal"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func displayExistedEntry() {
        guard let existedEntry = entry.bodyText else {
            return
        }
        textView.text = existedEntry
        if let existedDate = entry.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateField.text = dateFormatter.string(from: existedDate)
            dateField.textColor = UIColor.lightGray
        } else {
            dateField.text = ""
        }  
    }
}
