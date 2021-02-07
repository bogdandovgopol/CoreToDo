//
//  ViewController.swift
//  CoreToDo
//
//  Created by Bogdan on 4/2/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
        
    private lazy var dataSource: TDDataSource = {
        return TDDataSource(tableView: tableView) { (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = model.name
            return cell
        }
    }()
    
    private var items = [ToDoListItem]()
    
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        configureSearchController()
        
        getAllItems()
    }
    
    fileprivate func configureViewController() {
        title = "CoreData To Do List"
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddItemButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.frame = view.bounds
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadItems), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    fileprivate func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a task"
        searchController.searchBar.backgroundColor = .systemBackground
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
    }
    
    @objc
    fileprivate func onAddItemButtonPressed() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self](_) in
            guard let self = self else { return }
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            TDDataManager.shared.createItem(name: text) { (success) in
                if success {
                    self.getAllItems()
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    fileprivate func reloadItems() {
        getAllItems()
    }
    
    fileprivate func getAllItems() {
        TDDataManager.shared.getAllItems { [weak self](items) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.items = items
                self.dataSource.updateDataSource(on: items)
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        //display sheet with choice to edit, or cancel
        let sheet = UIAlertController(title: "What do you want to do?", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self](_) in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name

            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }

                TDDataManager.shared.updateItem(item: item, newName: newName) { (success) in
                    if success {
                        self.getAllItems()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }))

        present(sheet, animated: true)
    }
}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            isSearching = false
            DispatchQueue.main.async { self.dataSource.updateDataSource(on: self.items) }
            return
        }
        isSearching = true
        
        TDDataManager.shared.filterItems(name: filter) { [weak self](filteredItems) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.dataSource.updateDataSource(on: filteredItems) }
        }
    }
}

