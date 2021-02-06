//
//  TDDataSource.swift
//  CoreToDo
//
//  Created by Bogdan on 6/2/21.
//

import UIKit

enum Section { case main }
class TDDataSource: UITableViewDiffableDataSource<Section, ToDoListItem> {

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
            TDDataManager.shared.deleteItem(item: item) { [weak self](success) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        var snapshot = self.snapshot()
                        snapshot.deleteItems([item])
                        self.apply(snapshot)
                    }
                }
            }
        }
    }
}

