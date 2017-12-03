//
//  TodoTableViewController.swift
//  ToDoApp
//
//  Created by Olivia Sun on 11/25/17.
//  Copyright © 2017 Olivia Sun. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {

    @IBOutlet weak var showCompleted: UIBarButtonItem!
    // MARK: - Properties
    
    var resultsController: NSFetchedResultsController<Todo>!
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.title
        if (todo.dueDate == nil) {
            cell.detailTextLabel?.text = ""
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.detailTextLabel?.text = dateFormatter.string(from: todo.dueDate!)
            //set due date color to red if past due
            if (todo.dueDate?.compare(Date()).rawValue == -1){
                cell.detailTextLabel?.textColor = .red
            }
        }
        if todo.complete{
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
        if (todo.reminderDate != nil) {
            let image = #imageLiteral(resourceName: "bell-512")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 340, y: 15, width: 30, height: 30)
            cell.contentView.addSubview(imageView)
        }
        return cell
    }
    
    // MARK: - Table view delegate
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
        action.image = #imageLiteral(resourceName: "if_trash-o_1608715")
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
        action.image = #imageLiteral(resourceName: "if_Check_1063906")
        action.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
    }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        default:
            break
        }
    }

}










