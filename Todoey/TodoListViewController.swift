//
//  ViewController.swift
//  Todoey
//
//  Created by Hyoungbin Kook on 2018. 11. 12..
//  Copyright © 2018년 Hyoungbin Kook. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {
    
    // 참고로 UserDefault는 plist에 key:value 형태로 저장되는데, 얘는 UserDefault에서 무슨 값을 가져오려할 때 전체 리스트를 불러온다.
    // 실제 Data를 저장하기엔 비효율
    
    var itemArray = [Item]()
    
    // didSet은 seletedCategory에 value가 생겼을 때 실행된다.
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
 
    // AppDelegate.swift에 바로 접근할 수 없음. object가 아니라 class니까. 아래 방법을 통해 접근 가능
    // context는 실제 Database 앞에 있는 temporary한 영역이다. context에서 발생한 일을 영구적으로 만들려면 database에 저장해줘야 한다.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add New Items
    @IBAction func addButtomPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // 아래 Item은 DataModel 안에 있는 Entity 이름. 타입은 NSManagedObject인데 이게 CoreData Table에서 Row가 됨.
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    func saveItems() {

        do {
            try context.save()
        } catch {
            print("error saving context \(error)")
        }
        
        tableView.reloadData()
    }
 
    // parameter없이 콜하면 Item.fetchRequest() 라는 default value를 줄 것
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error \(error)")
        }
        
         tableView.reloadData()
        
    }
    
  

}


//MARK: - Search Bar Methods
// 한 class에 delegate가 너무 많은 것 같을 땐 extension을 통해서 분리.
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
            
            // 요청을 main 쓰래드에서 실행시킬 수 있게 한다.
            // searchBar가 responder를 내려놓게 한다.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}
