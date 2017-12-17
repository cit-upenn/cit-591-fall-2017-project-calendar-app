//
//  UpdateJournalViewController.swift
//  CalendarToDo
//
//  Created by Jiaying Wang on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//


import UIKit

// this class represents a controller of the updatejournal view
class UpdateJournalViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entry: Entry!

    // MARK: - outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    // this method is perform when the user updates and save the change
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
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 145/255, green: 190/255, blue: 231/255, alpha: 1.0)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Journal"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    // this method displays the journal's content that's already been saved
    func displayExistedEntry() {
        guard let existedEntry = entry.bodyText else {
            return
        }
        textView.text = existedEntry
        if let existedDate = entry.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateLabel.text = dateFormatter.string(from: existedDate)
            dateLabel.textColor = UIColor.lightGray
        } else {
            dateLabel.text = ""
        }  
    }
}
