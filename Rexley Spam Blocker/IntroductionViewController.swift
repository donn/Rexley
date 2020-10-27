//
//  IntroductionViewController.swift
//  Rexley Spam Blocker
//
//  Created by Donn on 2020-10-22.
//  Copyright © 2020 Donn. All rights reserved.
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
