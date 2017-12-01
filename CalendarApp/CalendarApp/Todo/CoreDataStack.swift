//
//  CoreDataStack.swift
//  ToDoApp
//
//  Created by Olivia Sun on 11/26/17.
//  Copyright © 2017 Olivia Sun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error \(error!)")
                return
            }
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}


