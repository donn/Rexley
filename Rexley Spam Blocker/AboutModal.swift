//
//  AboutModal.swift
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
import SwiftyStoreKit
import Cheers

class AboutModal: UIViewController {
    var cheerView: CheerView!
    @IBOutlet weak var loading: UIView!
    
    @IBOutlet weak var primaryStack: UIStackView!
    @IBOutlet weak var osaText: UITextView!
    
    @IBOutlet weak var iap1: RoundButton!
    @IBOutlet weak var iap3: RoundButton!
    @IBOutlet weak var iap5: RoundButton!
    
    var buttonMap: [String: RoundButton?]!
    
    func purchase(product id: String) {
        self.isModalInPresentation = true
        self.loading.isHidden = false
        for (_, button) in buttonMap {
            button?.isEnabled = false
            button?.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
        SwiftyStoreKit.purchaseProduct(id, quantity: 1, atomically: true) { result in
            DispatchQueue.main.async() {
                self.isModalInPresentation = false
                self.loading.isHidden = true
                for (_, button) in self.buttonMap {
                    button?.isEnabled = true
                    button?.backgroundColor = #colorLiteral(red: 0.9735608697, green: 0.266651392, blue: 0.2278730273, alpha: 1)
                }
                
            }
            switch result {
                case .success(let purchase):
                    DispatchQueue.main.async() {
                        self.cheerView.start()
                        let alert = UIAlertController(
                            title: "Thank you!",
                            message: "You've helped fund development of Rexley. You're awesome!",
                            preferredStyle: .alert
                        )

                        alert.addAction(UIAlertAction(title: "Yay!", style: .default, handler: { _ in
                            self.cheerView.stop()
                        }))

                        self.present(alert, animated: true)
                    }
                    
                    print("Purchase Success: \(purchase.productId)")
                case .error(let error):
                    
                    var errorMessageOptional: String? = nil
                    
                    switch error.code {
                        case .paymentCancelled: break
                        case .cloudServiceNetworkConnectionFailed:
                            errorMessageOptional = "Could not connect to the internet."
                        case .clientInvalid:
                            errorMessageOptional = "Client is invalid."
                        case .paymentInvalid:
                            errorMessageOptional = "The purchase identifier is invalid."
                        case .paymentNotAllowed:
                            errorMessageOptional = "The device is not allowed to make payments."
                        case .storeProductNotAvailable:
                            errorMessageOptional = "This in-app purchase is no longer available in your region."
                        case .cloudServicePermissionDenied:
                            fallthrough
                        case .cloudServiceRevoked:
                            errorMessageOptional = "You have not granted access to cloud service information."
                        case .unknown:
                            fallthrough
                        default:
                            errorMessageOptional = "An unknown error occurred while processing your payment."
                            NSLog((error as NSError).localizedDescription)
                    }
                    
                    if let errorMessage = errorMessageOptional {
                        DispatchQueue.main.async() {
                            let alert = UIAlertController(
                                title: "Payment Error",
                                message: errorMessage,
                                preferredStyle: .alert
                            )

                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        }
                    }
            }
        }
    }
    
    @IBAction func toggleOSA(_ sender: Any) {
        osaText.isHidden = !osaText.isHidden;
        primaryStack.isHidden = !osaText.isHidden;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let openSourceAcknowledgmentsFile = Bundle.main.path(forResource: "OSAcknowledgments", ofType: "txt")
//        let openSourceAcknowledgments = try! String(contentsOfFile: openSourceAcknowledgmentsFile!, encoding: .utf8)
//        osaText.text = openSourceAcknowledgments
        osaText.text = ":)"
        
        // Set up CheerView
        cheerView = CheerView()
        cheerView.frame = view.bounds
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        view.addSubview(cheerView)
        
        // Set up Buttons And Their Behavior
        buttonMap =  [
            GlobalConstants.iap1.rawValue: iap1,
            GlobalConstants.iap3.rawValue: iap3,
            GlobalConstants.iap5.rawValue: iap5
        ]
        
        for (_, button) in buttonMap {
            button?.titleLabel?.lineBreakMode = .byWordWrapping
            button?.titleLabel?.textAlignment = .center
        }
        
        SwiftyStoreKit.retrieveProductsInfo(Set<String>(buttonMap.keys)) { result in
            if let error = result.error {
                NSLog("FATAL: Unable to acquire IAPs. \(error)")
                return
            }
            
            for product in result.retrievedProducts {
                let id = product.productIdentifier
                
                guard let button = self.buttonMap[id] else {
                    fatalError("Retrieved product identifier not asked for.")
                }
                
                guard let priceString = product.localizedPrice else {
                    NSLog("Failed to obtain price.")
                    continue
                }
                
                button?.setTitle("\(priceString) Tip", for: .normal)
                button?.isEnabled = true
                button?.backgroundColor = #colorLiteral(red: 0.9735608697, green: 0.266651392, blue: 0.2278730273, alpha: 1)
                button?.onTouch = { _ in self.purchase(product: id) }
            }
            
            for id in result.invalidProductIDs {
                NSLog("Invalid product identifier: \(id)")
            }
        }
    }
    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Reset all settings?",
            message: "This will reset all the app settings for Rexley. This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            
        }))

        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            let dictionary = UserDefaults.group.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                UserDefaults.group.removeObject(forKey: key)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "website.donn.Rexley:SOFT RESET"), object: nil)
        }))

        self.present(alert, animated: true)
    }
}
