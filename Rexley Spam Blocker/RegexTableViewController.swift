//
//  AppDelegate.swift
//
//  Copyright © 2020 Mohamed Gaber. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import IdentityLookup

class RegexCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var indicator: UITextField!
    @IBOutlet weak var targetAction: UIButton!
}

class PlusCell: UITableViewCell {
    @IBOutlet weak var plusButton: UIButton!
}

class RegexTableViewController: UITableViewController {
    
    var regexList: [Filter] = []
    var dispatchQueue = DispatchQueue(label: "deletedObjectQueue", attributes: .concurrent)
    var deleteQueue: [Filter] = []
    
    var editMode = 0
    
    var addAction: UIAction!
    var globalEditAction: UIAction!
    
    func saveRegexList() {
        let result = UserDefaults.group.setCodable(regexList, forKey: "RegexList") != nil
        if !result {
            NSLog("Alert: Save failed.")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
         NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAbout),
            name: Notification.Name(rawValue: "website.donn.Rexley:SHOW ABOUT"),
            object: nil
        )
        self.regexList = UserDefaults.group.getCodable(forKey: "RegexList", using: [Filter].self) ?? []
        if self.regexList.count == 0 {
            self.addPressed(self)
        }
        
        self.addAction = UIAction(
            title: "New",
            image: UIImage(systemName: "plus.circle")
        ) {
            _ in
            self.addPressed(self)
        }
        
        self.globalEditAction = UIAction(
            title: self.tableView.isEditing ? "Done" : "Edit",
            image: UIImage(systemName: "pencil.and.ellipsis.rectangle")
        ) {
            _ in
            self.editPressed(self)
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Editing
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editPressed(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        let path = IndexPath(row: regexList.count, section: 0)
        if (self.tableView.isEditing) {
            editMode = 1
            self.tableView.insertRows(at: [path], with: .automatic)
            self.editButton.title = "Done"
        } else {
            editMode = 0
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.editButton.title = "Edit"
        }
    }
    
    // MARK: - Table View
    @IBAction func addPressed(_ sender: Any) {
        self.regexList.append(Filter(pattern: nil, field: nil))
        saveRegexList()
        let path = IndexPath(row: regexList.count - 1, section: 0)
        self.tableView.insertRows(at: [path], with: .automatic)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regexList.count + editMode
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if (index == regexList.count) {
            return tableView.dequeueReusableCell(withIdentifier: "PlusCell", for: indexPath) as! PlusCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegexCell", for: indexPath) as! RegexCell

        let filter = regexList[index]

        if let pattern = filter.pattern {
            cell.label.text = pattern
            cell.label.textColor = filter.caseSensitive ? #colorLiteral(red: 0.9732629657, green: 0.2652953863, blue: 0.2297978401, alpha: 1) : UIColor.label
        } else {
            cell.label.text = "New Filter"
            cell.label.textColor = UIColor.secondaryLabel
        }
        
        if filter.regex {
            cell.label.font = UIFont(descriptor: UIFontDescriptor(name: "Menlo", size: 18), size: 18)
        } else {
            cell.label.font = UIFont.systemFont(ofSize: 18)
        }
        
        switch (filter.field) {
        case .sender:
            cell.indicator.backgroundColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
            cell.indicator.text = "Sender"
        case .messageBody:
            cell.indicator.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            cell.indicator.text = "Body"
        case nil:
            cell.indicator.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            cell.indicator.text = "All"
        }
        
        switch (filter.action) {
        case .transaction:
            cell.targetAction.setImage(UIImage(systemName: "arrow.right.arrow.left"), for: .normal)
        case .promotion:
            cell.targetAction.setImage(UIImage(systemName: "burst"), for: .normal)
        default:
            cell.targetAction.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.row != regexList.count
    }
    
    override func tableView(_ table: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Return false if you do not want the specified item to be selectable.
        return (indexPath.row != regexList.count) ? indexPath : nil
    }
    
    func deleteRow(at indexPath: IndexPath) {
        let reference = regexList.remove(at: indexPath.row)
        saveRegexList()
        tableView.deleteRows(at: [indexPath], with: .fade)
        if regexList.count == 0 {
            self.addPressed(self)
        }
        dispatchQueue.async(flags: .barrier) {
            self.deleteQueue.push(reference)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "website.donn.Rexley:FILTER DELETED"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRow(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) {
            _ in
            return UIMenu(
                title: "Actions",
                children: [
                    self.addAction,
                    UIAction(
                        title: "Edit",
                        image: UIImage(systemName: "pencil.and.ellipsis.rectangle")
                    ) {
                        _ in
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        self.performSegue(withIdentifier: "editSegue", sender: tableView)
                    },
                    UIAction(
                        title: "Delete",
                        image: UIImage(systemName: "trash")
                    ) {
                        _ in
                        self.deleteRow(at: indexPath)
                    }
                ]
            )
        }
    }

    // MARK: - Navigation
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "editSegue" {
            let detail = segue.destination as! DetailViewController
            detail.current = self.regexList[self.tableView.indexPathForSelectedRow!.row]
            detail.presenter = self
        }
    }
    
    @objc func showAbout() {
        performSegue(withIdentifier: "aboutSegue", sender: self)
    }
    
    @IBAction func back(unwindSegue: UIStoryboardSegue) {}

}
