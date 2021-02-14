//
//  ViewController.swift
//  Todoey
//
//  Created by Ivan Ivanov on 2/12/21.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryView: SwipeTableViewController {
    let realm = try! Realm()
    
    var caterories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        loadCategories()
    }
    // MARK: - TableView DataSource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        caterories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = caterories?[indexPath.row].name ?? "No categories yet"
        
        if let color = UIColor(hexString: caterories?[indexPath.row].color ?? "1D9BF6"){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
        
    }
    
    // MARK: - TableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.seguaConnection, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinatinVC = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinatinVC.selectedCategory = caterories?[indexPath.row]
        }
    }
    
    // MARK: - Add NewCategories
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let textFieldData = alert.textFields![0]
            
            
            
            let randomColor = UIColor.randomFlat().hexValue()
            let newCategory = Category()
            newCategory.name = textFieldData.text!
            newCategory.color = randomColor
            
            self.saveData(newCategory)
            
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Create new Category"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Save Data
    func saveData(_ category: Category){
        do{
            try realm.write{
                realm.add(category)
                print("Succesfully added")
            }
        }catch{
            print("Error saving context\(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: - LoadData
    func loadCategories(){
        caterories = realm.objects(Category.self)
        
    }
    
   
    // MARK: - UPdate Data
    
    override func updateModel(_ indexPath: IndexPath){
        if let itemForDelete = caterories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDelete)
                }
            }catch{
                print("Error with delete category \(error)")
            }
        }
    }
    
}

