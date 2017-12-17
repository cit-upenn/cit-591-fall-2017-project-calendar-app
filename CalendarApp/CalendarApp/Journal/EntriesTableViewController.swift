//
//  EntriesTableViewController.swift
//  CalendarToDo
//
//  Created by Jiaying Wang on 11/29/17.
//  Copyright © 2017 CalendarApp. All rights reserved.
//


import UIKit
import CoreData

// this class represents the controller of the jounal entry table view
class EntriesTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entries: [Entry] = []
    var filterEntries: [Entry] = []
    var selectedRow: Int!
    
    
    // This method is called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupNavBar()
    }
    
    // this method sets up the navigation bar
    func setupNavBar(){
        //setup navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Journal"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    // this method sets up the search bar
    func setupSearchBar(){
        //setup search bar
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController

        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.delegate = self
        searchController.searchBar.backgroundColor = UIColor(red: 145/255, green: 190/255, blue: 231/255, alpha: 1.0)
    }
    
    // this method tells the delegate that the user changed the search text.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if (searchText.isEmpty || (searchBar.text?.isEmpty)!) {
            filterEntries = entries
        } else {
            filterEntries = entries.filter {($0.bodyText?.lowercased().contains(searchText.lowercased()))! }
        }
        self.tableView.reloadData()
    }
    
    // this method tells the delegate that the user finished editing the search text.
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.isEmpty)! {
            self.filterEntries = self.entries
            self.tableView.reloadData()
        }
    }

    // this method notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchEntries()

    }

    // this mthod fetches jounal entries store in coredata
    func fetchEntries() {
        do {
            entries = try context.fetch(Entry.fetchRequest())
            filterEntries = entries
        } catch let error as NSError {
            print("Could not fetch entries: \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    // this method is called when user taps on the entry
    @IBAction func ComposeDidClick(_ sender: Any) {
        self.performSegue(withIdentifier: "addNew", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table view data source
   
    // this method asks the data source to return the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    // this method tells the data source to return the number of rows in a given section of a table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.filterEntries.count
    }

    // this method asks the data source for a cell to insert in a particular location of the journal entry table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = filterEntries.reversed()[indexPath.row].bodyText
        
        if let date = filterEntries.reversed()[indexPath.row].createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    //override to perform segue when select a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        performSegue(withIdentifier: "update", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // this method asks the delegate for the actions to display in response to a swipe in the specified row.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            let entry = self.filterEntries.reversed()[indexPath.row]
            self.context.delete(entry)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.fetchEntries()
        }
        delete.backgroundColor = UIColor(red: 36/255, green: 39/255, blue: 148/255, alpha: 1.0)
        return [delete]
    }
 
    // MARK: - Navigation

    // this method notifies the view controller that a segue to "updatejournalview" is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "update" {
            let update = segue.destination as! UpdateJournalViewController
            update.entry = filterEntries.reversed()[selectedRow!]
        }
    }
}

    


