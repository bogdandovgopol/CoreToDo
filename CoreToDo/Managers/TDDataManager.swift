//
//  ToDoDataManager.swift
//  CoreToDo
//
//  Created by Bogdan on 5/2/21.
//

import UIKit
import CoreData

class TDDataManager {
    
    let persistantContainer: NSPersistentContainer
    
    init() {
        persistantContainer = NSPersistentContainer(name: "CoreToDo")
        persistantContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
//            persistantContainer.viewpersistantContainer.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    
    
//    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /// This function gets all to do items saved in CoreData
    /// - Returns: Returns array of ToDoListItem
    func getAllItems() -> [ToDoListItem] {
        do {
            let items: [ToDoListItem] = try persistantContainer.viewContext.fetch(ToDoListItem.fetchRequest())
            return items
        } catch {
            persistantContainer.viewContext.rollback()
            return []
        }
    }
    
    /// This function created a to do list item
    /// - Parameters:
    ///   - name: Name of item eg. "Learn CoreData"
    /// - Returns: Returns true if item successfully saved
    func createItem(name: String) -> Bool {
        let newItem = ToDoListItem(context: persistantContainer.viewContext)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try persistantContainer.viewContext.save()
            return true
        } catch{
            persistantContainer.viewContext.rollback()
            return false
        }
    }
    
    /// This function deletes an item from CoreData
    /// - Parameters:
    ///   - item: ToDoListItem
    /// - Returns: Returns true if item successfully deleted
    func deleteItem(item: ToDoListItem) -> Bool {
        persistantContainer.viewContext.delete(item)
        
        do {
            try persistantContainer.viewContext.save()
            return true
        } catch{
            persistantContainer.viewContext.rollback()
            return false
        }
    }
    
    /// This function updates item in CoreData
    /// - Parameters:
    ///   - item: ToDoListItem
    ///   - newName: new to to list item name
    /// - Returns: Returns true if item successfully updated
    func updateItem(item: ToDoListItem, newName: String) -> Bool {
        item.name = newName
        
        do {
            try persistantContainer.viewContext.save()
            return true
        } catch{
            persistantContainer.viewContext.rollback()
            return false
        }
    }
    
    /// This function filters CoreData items by name
    /// - Parameters:
    ///   - name: Name of a task you want to search for
    /// - Returns: Returns filtered array of items sorted in ascending order by name
    func filterItems(name: String) -> [ToDoListItem] {
        do {
            let request: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
            let sort = NSSortDescriptor(key: "name", ascending: true)
            
            request.predicate = predicate
            request.sortDescriptors = [sort]
            
            let filteredItems = try persistantContainer.viewContext.fetch(request)
            return filteredItems
        } catch {
            persistantContainer.viewContext.rollback()
            return []
        }
    }
}
