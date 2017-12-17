//
//  TodoTableViewController.swift
//  ToDoApp
//
//  Created by Olivia Sun on 11/25/17.
//  Copyright © 2017 Olivia Sun. All rights reserved.
//

import UIKit
import CoreData

// this class represents the controller of the todo table view 
class TodoTableViewController: UITableViewController {

    @IBOutlet weak var showCompleted: UIBarButtonItem!
    // MARK: - Properties
    
    var resultsController: NSFetchedResultsController<Todo>!
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // This function is called after the view controller has loaded its view hierarchy into memory.
    // It will request data from the persistent container,
    // filter out all the todos that are not checked,
    // and present to the tableview by ascending due date and title.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        
        // Request
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: "dueDate", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "title", ascending: true)
        
        // Init
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        request.predicate = NSPredicate(format: "complete == false")
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self
        
        // Fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
    
    }
    
    //setup navigation bar
    func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Todo"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30),NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    // MARK: - Table view data source

    //this function tells the data source to return the number of rows in a given section of a table view.
    //if there is not data yet, it will return 0
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    // this function asks the NSManagedObjectResultsController for a cell to insert in a particular location of the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = resultsController.object(at: indexPath)
        
        //set title and title color
        cell.textLabel?.text = todo.title
        if todo.complete{
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        
        //set subtitle
        if (todo.dueDate == nil) {
            cell.detailTextLabel?.text = ""
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let due = dateFormatter.string(from: todo.dueDate!)
            cell.detailTextLabel?.text = "Due date: \(due)"
            //set due date color to red if past due
            if (todo.dueDate?.compare(Date()).rawValue == -1 && !todo.complete){
                cell.detailTextLabel?.textColor = .red
            }
        }
       
        
        //setting up remind bell for each todo item
        let image = #imageLiteral(resourceName: "bell-512")
        let imageView = UIImageView(image: image)
        
        if todo.dueDate != nil && todo.reminderDate != nil {
            // remove bell if there exists one
            for view in cell.contentView.subviews {
                if let view = view as? UIImageView {
                    view.removeFromSuperview()
                }
            }
            let yOffset = 20
            imageView.frame = CGRect(x: 350, y: yOffset, width: 20, height: 20)
            cell.contentView.addSubview(imageView)
        } else if todo.dueDate == nil && todo.reminderDate != nil {
            let yOffset = 12
            imageView.frame = CGRect(x: 350, y: yOffset, width: 20, height: 20)
            cell.contentView.addSubview(imageView)
        } else {
            for view in cell.contentView.subviews {
                if let view = view as? UIImageView {
                    view.removeFromSuperview()
                }
            }
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    // this function returns the "delete" action to display on the trailing edge of the row
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { ( action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Delete failed: \(error)")
                completion(false)
            }
        }
        action.title = "Delete"
        action.backgroundColor = UIColor.init(colorWithHexValue: 0x242794)
        
        return UISwipeActionsConfiguration(actions: [action])
    }

    // this function returns the "check" action to display on the leading edge of the row.
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //checked item won't have this action
        let todo = self.resultsController.object(at: indexPath)
        if todo.complete {return nil}
        //configuration for unfinished items
        let action = UIContextualAction(style: .normal, title: "Check") { ( action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            todo.complete = true
            do {
                try self.resultsController.managedObjectContext.save()
                tableView.reloadData()
                completion(true)
            } catch {
                print("Check failed: \(error)")
                completion(false)
            }
        }
        action.title = "Check"
        action.backgroundColor = UIColor.init(colorWithHexValue: 0xffb735)
        
        return UISwipeActionsConfiguration(actions: [action])
    }
 
    //select a row, if unfinished -> edit page, otherwise no interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = self.resultsController.object(at: indexPath)
        if todo.complete {return}
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
    }
  
    // MARK: - Navigation

    // this function notifies the view controller that the AddTodoView segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell){
                let todo = resultsController.object(at: indexPath)
                vc.todo = todo
            }
        }
    }
    
    // show completed/hide completed tasks
    @IBAction func showCompleted(_ sender: UIBarButtonItem) {
        if sender.title == "Show Completed" {
            
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
            resultsController.fetchRequest.predicate = nil
            
            sender.title = "Hide Completed"
        } else {
            
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
            resultsController.fetchRequest.predicate = NSPredicate(format: "complete == false")

            sender.title = "Show Completed"
        }
        do {
            try resultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
    }
}


extension TodoTableViewController:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //this function notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            tableView.reloadData()
//         default:
//            break
        }
    }

}










