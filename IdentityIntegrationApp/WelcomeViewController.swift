
/* Copyright (c) 2021 CyberArk Software Ltd. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit

class WelcomeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var body_textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension WelcomeViewController {
    func configure() {
        body_textView.attributedText = getAttributedString()
        body_textView.delegate = self
        body_textView.textAlignment = .center
        body_textView.isEditable = false
        body_textView.isSelectable = true
        body_textView.dataDetectorTypes = .link

    }
    func getAttributedString() -> NSMutableAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let normalText = "Welcome to Acme Inc. !!​\n​\nAcme Inc. is a banking company using CyberArk Identity APIs, SDKs, and widgets to secure its web applications. This playground application shows all the possible variations that a developer from Acme has at their disposal. ​\n​\nFor developer guides and API documentation, please visit CyberArk Identity Developer Program website.​\n\n"
        
        let attributedString = normalText.getLinkAttributes(header: "Welcome to Acme Inc. !!", linkAttribute: "CyberArk Identity Developer Program", headerFont: UIFont.boldSystemFont(ofSize: 25.0), textFont:  UIFont.boldSystemFont(ofSize: 15.0), color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), underLineColor: .blue, linkValue: "https://identity-developer.cyberark.com/")
        
        return attributedString
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        launchURL()
        return true
    }
    func launchURL() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: "https://identity-developer.cyberark.com/") {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
}
