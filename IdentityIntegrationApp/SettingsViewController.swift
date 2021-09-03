//
//  SettingsViewController.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 31/08/21.
//

import UIKit
import Identity

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tenant_textfeild: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        tenant_textfeild.delegate = self
        addDoneButtonOnKeyboard(textFeild: tenant_textfeild)
    }
    
}
extension SettingsViewController {
    func config(){
        guard let config = plistValues(bundle: Bundle.main) else { return }
        tenant_textfeild.text = config.domain
    }
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String)? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, threshold: threshold, applicationID: applicationID, logouturi: logouturi)
    }
}
extension SettingsViewController {
    func addDoneButtonOnKeyboard(textFeild: UITextField){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textFeild.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        
        if let urlString = tenant_textfeild.text {
            if urlString.isValidURL {
                var url = urlString
                if (!urlString.lowercased().hasPrefix("http://") || !urlString.lowercased().hasPrefix("https://")) {
                    url = "https://\(url)"
                }
                //updatePlist(domain: url)
                tenant_textfeild.resignFirstResponder()
            } else {
                showAlert(message: "Please provide valid url...")
            }
        }
    }
    /*func updatePlist(domain: String){
        guard
            let path = Bundle.main.path(forResource: "IdentityConfiguration", ofType: "plist"),
            var values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return
        }
        values["domainautho"] = domain
        values.writeToFile(path, atomically: true)
    }*/
    
}
