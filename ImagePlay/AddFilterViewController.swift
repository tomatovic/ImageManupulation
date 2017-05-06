//
//  AddFilterViewController.swift
//  ImagePlay
//
//  Created by Robert Patterson on 2016-03-20.
//  Copyright © 2016 robbo. All rights reserved.
//

import UIKit

class AddFilterViewController: UITableViewController {

    var filtersModel: FiltersModel = FiltersModel()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFilters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFilterProto", for: indexPath)
        cell.textLabel?.text = allFilters[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = allFilters[indexPath.row]
        filtersModel.filters.append(selectedItem)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FiltersUpdated"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
}
