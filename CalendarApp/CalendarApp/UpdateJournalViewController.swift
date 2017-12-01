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
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
