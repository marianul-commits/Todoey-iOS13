//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
        
        //MARK: - Tableview Datasource Methods
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard (itemArray != nil) else{
                return 0
            }
            return itemArray.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
                        
            let item = itemArray[indexPath.row]
            
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
            return cell
            
        }
        
        
        
        //MARK: - Tableview Delegate Methods
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            
            saveItems()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        //MARK: -- Add new items
        
        @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
            
            var textField = UITextField()
                        
            let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                
                if textField.text != ""{
                    self.itemArray.append(newItem)
                    self.saveItems()
                } else {
                    let error = UIAlertController(title: "Error", message: "Cannot add empty task", preferredStyle: .alert)
                    let errorAction = UIAlertAction(title: "OK", style: .default)
                    error.addAction(errorAction)
                    self.present(error, animated: true, completion: nil)
                }
                
            }
            
            alert.addTextField { (alertTextFied) in
                alertTextFied.placeholder = "Create new item"
                textField = alertTextFied
            }
            
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
            
        }
        
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        do{
            try context.save()
        } catch {
           print("error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do{
           itemArray = try context.fetch(request)
        } catch {
            print("error fetching \(error)")
        }
    }
    
    
    
}
    
