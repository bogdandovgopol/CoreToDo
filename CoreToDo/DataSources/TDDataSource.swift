//
//  TDDataSource.swift
//  CoreToDo
//
//  Created by Bogdan on 6/2/21.
//

import UIKit

enum Section { case main }
final class TDDataSource: UITableViewDiffableDataSource<Section, ToDoListItem> {
    
    private var tdDataManager: TDDataManager!
    
    override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, ToDoListItem>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    convenience init(dataManager: TDDataManager, tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, ToDoListItem>.CellProvider) {
        self.init(tableView: tableView, cellProvider: cellProvider)
        self.tdDataManager = dataManager
    }

    func updateDataSource(on items: [ToDoListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDoListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        snapshot.reloadItems(items)
        
        apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let item = itemIdentifier(for: indexPath) else { return }
            let itemDeleted = tdDataManager.deleteItem(item: item)
            DispatchQueue.main.async {
                if itemDeleted {
                    var snapshot = self.snapshot()
                    snapshot.deleteItems([item])
                    self.apply(snapshot)
                }
            }
        }
    }
}

