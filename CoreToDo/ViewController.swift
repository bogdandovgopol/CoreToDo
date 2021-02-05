//
//  ViewController.swift
//  CoreToDo
//
//  Created by Bogdan on 4/2/21.
//

import UIKit

class ViewController: UIViewController {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "CoreData To Do List"
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddItemButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
        navigationController?.navigationBar.prefersLargeTitles = true

        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        getAllItems()
    }
    
    @objc func onAddItemButtonPressed() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self](_) in
            guard let self = self else { return }
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            ToDoDataManager.shared.createItem(name: text) { [weak self](success) in
                guard let self = self else { return }
                if success {
                    self.getAllItems()
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    func getAllItems() {
        DispatchQueue.main.async {
            ToDoDataManager.shared.getAllItems { [weak self](items) in
                guard let self = self else { return }
                guard let items = items else { return }
                
                self.models = items
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self](_) in
                guard let self = self else { return }
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                
                ToDoDataManager.shared.updateItem(item: item, newName: newName) { [weak self](success) in
                    guard let self = self else { return }
                    if success {
                        self.getAllItems()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self](_) in
            guard let self = self else { return }
            ToDoDataManager.shared.deleteItem(item: item) { [weak self](success) in
                guard let self = self else { return }
                if success {
                    self.getAllItems()
                }
            }
        }))
        
        present(sheet, animated: true)
    }
    
    
}

