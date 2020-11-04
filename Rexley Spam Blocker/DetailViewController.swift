//
//  DetailViewController.swift
//  Rexley Spam Blocker
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
import Regex
import IdentityLookup

class DetailViewController: UIViewController, UITextFieldDelegate {
    var current: Filter?
    weak var presenter: RegexTableViewController?
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var regexVsTextSegment: UISegmentedControl!
    @IBOutlet weak var pattern: UITextField!
    @IBOutlet weak var fieldSegment: UISegmentedControl!
    @IBOutlet weak var actionSegment: UISegmentedControl!
    @IBOutlet weak var caseSensitiveSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    var field: Field? {
        var field: Field?
        switch fieldSegment.selectedSegmentIndex {
        case 0:
            field = .sender
        case 1:
            field = .messageBody
        default:
            field = nil
        }
        return field
    }
    
    var regex: Bool {
        return regexVsTextSegment.selectedSegmentIndex == 1
    }
    
    var caseSensitive: Bool {
        return caseSensitiveSwitch.isOn
    }
    
    var action: ILMessageFilterAction {
        switch actionSegment.selectedSegmentIndex {
        case 0:
            return .promotion
        case 1:
            return .transaction
        default:
            return .junk
        }
    }
    
    #if !targetEnvironment(macCatalyst) // On macOS Catalyst, the Save Key Command is handled via the top menu.
    override var keyCommands: [UIKeyCommand] {
        return [UIKeyCommand(title: "Save", action: #selector(savePressed), input: "S", modifierFlags: [.command])]
    }
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.pattern.delegate = self
        updateElements()
        
         NotificationCenter.default.addObserver(
            self,
            selector: #selector(deletionResponder),
            name: Notification.Name(rawValue: "website.donn.Rexley:FILTER DELETED"),
            object: nil
        )
        
        // On macOS Catalyst, Menu Bar Save Command
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(savePressed),
            name: Notification.Name(rawValue: "website.donn.Rexley:SAVE"),
            object: nil
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func deletionResponder() {
        if let presenter = self.presenter {
            presenter.dispatchQueue.sync {
                while let filter = presenter.deleteQueue.pop() {
                    if filter === current {
                        current = nil
                    }
                }
            }
        }
        updateElements()
    }
    
    func updateElements() {
        if let set = current {
            header.text = set.pattern == nil ?
                "New Filter":
                "Update Filter"
            
            regexVsTextSegment.selectedSegmentIndex = set.regex ? 1 : 0
            
            pattern.text = set.pattern
            
            switch set.field {
            case .sender:
                fieldSegment.selectedSegmentIndex = 0
            case .messageBody:
                fieldSegment.selectedSegmentIndex = 1
            default:
                fieldSegment.selectedSegmentIndex = 2
            }
            
            switch set.action {
            case .promotion:
                actionSegment.selectedSegmentIndex = 0
            case .transaction:
                actionSegment.selectedSegmentIndex = 1
            default:
                actionSegment.selectedSegmentIndex = 2
            }
            
            caseSensitiveSwitch.isOn = set.caseSensitive
            
        }
        updateBehavior()
    }
    
    func updateBehavior() {
        var edited = false
        if let current = self.current {
            pattern.textColor = UIColor.label
            saveButton.isEnabled = true
            if (regex) {
                pattern.placeholder = "^[Cc]ongratulations"
                pattern.font = UIFont(descriptor: UIFontDescriptor(name: "Menlo", size: 17), size: 17)
                do {
                    let patternStr = pattern.text ?? ""
                    let _ = try Regex(pattern: patternStr)
                    saveButton.isEnabled = patternStr.count > 0
                } catch {
                    pattern.textColor = #colorLiteral(red: 0.9735608697, green: 0.266651392, blue: 0.2278730273, alpha: 1)
                    saveButton.isEnabled = false
                }
            } else {
                pattern.placeholder = "Congratulations"
                pattern.font = UIFont.systemFont(ofSize: 17.0)
            }
            
            edited =
                (current.pattern ?? "") != (self.pattern.text ?? "") ||
                current.field != self.field ||
                current.caseSensitive != self.caseSensitive ||
                current.regex != self.regex ||
                current.action != self.action
        }


        stackView.isHidden = current == nil

        saveButton.tintColor = edited ? #colorLiteral(red: 0.9529411765, green: 0.3333333333, blue: 0.2549019608, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        saveButton.isEnabled = edited
    }
        
    @IBAction func edited(_ sender: Any) {
         updateBehavior()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if let current = self.current, saveButton.isEnabled {
            let pattern = self.pattern.text ?? ""
            var field: Field? = nil
            switch fieldSegment.selectedSegmentIndex {
            case 0:
                field = .sender
            case 1:
                field = .messageBody
            default:
                field = nil
            }
            current.pattern = pattern
            current.field = field
            current.caseSensitive = caseSensitive
            current.regex = regex
            current.action = action
            presenter?.tableView.reloadData()
            presenter?.saveRegexList()
            updateBehavior()
        }
    }
    
}
