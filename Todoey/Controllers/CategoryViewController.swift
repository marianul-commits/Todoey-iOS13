//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Marian Nasturica on 24.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    var categories = [Category]()
    
    let catContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("We don fucked up with nav controller")
            }
            navBar.backgroundColor = UIColor(hexString: "1D9BF6")
            
            if let navBarCoulour = UIColor(hexString: "1D9BF6") {
                navBar.tintColor = ContrastColorOf(navBarCoulour, returnFlat: true)}
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard (categories.count != 0) else{
            return 0
        }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        var colour = categories[indexPath.row].color
        
        cell.backgroundColor = UIColor(hexString: colour ?? "1D9BF6")
        
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: colour ?? "1D9BF6")!, returnFlat: true)
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var catTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.catContext)
            newCategory.name = catTextField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            if catTextField.text != ""{
                self.categories.append(newCategory)
                self.saveCategory()
            } else {
                let error = UIAlertController(title: "Error", message: "Cannot add empty category", preferredStyle: .alert)
                let errorAction = UIAlertAction(title: "OK", style: .default)
                error.addAction(errorAction)
                self.present(error, animated: true, completion: nil)
            }
            
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Create new category"
            catTextField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory() {
        do{
            try catContext.save()
        } catch {
            print("error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do{
            categories = try catContext.fetch(request)
        } catch {
            print("error fetching \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        self.catContext.delete(self.categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
    }
    
}
