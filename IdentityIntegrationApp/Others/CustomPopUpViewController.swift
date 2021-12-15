
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


class CustomPopUpViewController: UIViewController {
    
    typealias PopUpCompletionHandler = (() -> Void)

    private var observers = [String: PopUpCompletionHandler]()

    @IBOutlet var message_textview: UITextView!

    var handler: PopUpCompletionHandler?
    var labelTitle: String = ""
    var text: String = ""
    var meessageAtributedText: NSMutableAttributedString? 

    var popUpType: PopUpType = .success
    var continueHandler: PopUpCompletionHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        configure()
    }
    func configure() {
        message_textview.attributedText = meessageAtributedText
        message_textview.textAlignment = .center
        message_textview.isEditable = false
        message_textview.isSelectable = true
        message_textview.isUserInteractionEnabled = true
        message_textview.dataDetectorTypes = .link
    }
    func callCompletion(completionHandler: @escaping PopUpCompletionHandler) {
        handler = completionHandler
    }
    func continueCallCompletion(completionHandler: @escaping PopUpCompletionHandler) {
        continueHandler = completionHandler
    }

    @IBAction func actionHandler(_ sender: Any) {
        handler!()
    }
    @IBAction func continueHandler(_ sender: Any) {
        continueHandler!()
    }
}

public enum PopUpType {
    case success
    case failure
    case validation
}

public enum PopUpActionType {
    case success
    case failure
    case defaultCase
}
