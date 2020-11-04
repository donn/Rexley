//
//  IntroductionViewController.swift
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

@IBDesignable
class RoundStackView: UIStackView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}


class IntroductionViewController: UIViewController {
    override func viewDidLoad() {
        self.isModalInPresentation = true
    }
    @IBAction func startTapped(_ sender: Any) {
       let _ = UserDefaults.group.setCodable(true, forKey: "initialLaunchPerformed")
    }

}
