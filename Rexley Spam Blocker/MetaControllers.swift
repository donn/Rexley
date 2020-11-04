//
//  MetaControllers.swift
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

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst) // Hide Navbar and Toolbar in macOS Catalyst (Aesthetic)
        self.setNavigationBarHidden(true, animated: false)
        self.setToolbarHidden(true, animated: false)
        #endif
        // Do any additional setup after loading the view.
    }

}

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .oneBesideSecondary
    }
    
    func splitViewController(
             _ splitViewController: UISplitViewController,
             collapseSecondary secondaryViewController: UIViewController,
             onto primaryViewController: UIViewController
    ) -> Bool {
        return true
    }
}


extension UISplitViewController {
    var master: UIViewController? {
        return self.viewControllers.first
    }

    var detail: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }
}
