//
//  ItemViewController.swift
//  Todoey
//
//  Created by Ivan Ivanov on 2/12/21.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var items: Results<Items>?
    
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        loadItems()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("There is not navBar")
        }
        if let category = selectedCategory {
            title = category.name
            if let colorHex = category.color {
                
                searchBar.barTintColor = UIColor(hexString: colorHex)
                if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                    textfield.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    textfield.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
                
                navBar.tintColor = ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)
                navBar.barTintColor = UIColor(hexString: colorHex)
                navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)]
                
            }
        }
        
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = items?[indexPath.row].title ?? "There is no Items"
        
        if let backGroundColor = selectedCategory?.color {
            
            let percentage = CGFloat(indexPath.row) / CGFloat(items!.count)
            let newColor = UIColor(hexString: backGroundColor)?.darken(byPercentage: percentage)
            
            cell.backgroundColor = newColor
            cell.textLabel?.textColor = ContrastColorOf(newColor!, returnFlat: true)
            
            
        }
        cell.accessoryType = items![indexPath.row].isDone ? .checkmark : .none
        
        
        
        return cell
    }
    
  // MARK: - TableView Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row]{
            do{
                try realm.write{
                    item.isDone = !item.isDone
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }catch{
                print("Change property isDone \(error)")
            }
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            
            
        }
    }
    // MARK: - Add New Items
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Items", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Items", style: .default) { (action) in
            let textField = alert.textFields![0]
            
            if let currentCategory = self.selectedCategory{
                
                
                do{
                    try self.realm.write{
                        let newItem = Items()
                        newItem.title = textField.text!
                        newItem.date = Date()
                        currentCategory.items.append(newItem)
                        
                        
                    }
                }catch{
                    print("CanNot save items data")
                    
                }
            }
            self.tableView.reloadData()
            
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Add some Items"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - LoadItems
    
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
        
        // MARK: - deleteItem
        
    }
    override func updateModel(_ indexPath: IndexPath) {
        if let itemForDelete = items?[indexPath.row]{
            do{
                try realm.write{
                     realm.delete(itemForDelete)
                }
            }catch{
                print{"Error with delete item \(itemForDelete)"}
            }
        }
    }
    
    
    
}



// MARK: - SearchBar Delegate
extension ItemViewController: UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
        
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

