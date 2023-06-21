//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem.title = "Destroy the gov"
        itemArray.append(newItem)
        
        let newItem3 = Item()
        newItem.title = "get rich die trying"
        itemArray.append(newItem)
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
            itemArray = items
            
        }
    }
        
        //MARK: - Tableview Datasource Methods
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            
            tableView.reloadData()
            
        }
        
        //MARK: -- Add new items
        
        @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
            
            var textField = UITextField()
            
            let newItem = Item()
            newItem.title = textField.text ?? ""
            
            let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                if textField.text != ""{
                    self.itemArray.append(newItem)
                    self.defaults.set(self.itemArray, forKey: "ToDoListArray")
                    self.tableView.reloadData()
                    print("added")
                } else {
                    let error = UIAlertController(title: "Error", message: "Cannot add empty task", preferredStyle: .alert)
                    let errorAction = UIAlertAction(title: "OK", style: .default)
                    error.addAction(errorAction)
                    self.present(error, animated: true, completion: nil)
                    print("not added")
                }
                
            }
            
            alert.addTextField { (alertTextFied) in
                alertTextFied.placeholder = "Create new item"
                textField = alertTextFied
            }
            
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
