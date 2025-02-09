//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            
            
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("We don fucked up with nav controller")
            }
            
            if let navBarCoulour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarCoulour
                navBar.tintColor = ContrastColorOf(navBarCoulour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarCoulour, returnFlat: true)]
                searchBar.barTintColor = navBarCoulour
                
            }
            

        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard (itemArray.count != 0) else{
            return 0
        }
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        if let colour = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(itemArray.count))) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        
       
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        
        return cell
        
    }
    
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            newItem.parentCategory = self.selectedCategory
            
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
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(self.itemArray[indexPath.row])
        self.itemArray.remove(at: indexPath.row)
    }
    
}

//MARK: - Searchbar Delegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

