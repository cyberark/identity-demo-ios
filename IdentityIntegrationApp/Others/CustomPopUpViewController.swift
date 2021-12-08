//
//  PopUpAlertOkCancelStyleViewController.swift
//  vCard
//
//  Created by Mallikarjuna Reddy P on 27/10/20.
//  Copyright © 2020 Mallikarjuna Reddy P. All rights reserved.
//

import UIKit


class CustomPopUpViewController: UIViewController {
    
    typealias PopUpCompletionHandler = (() -> Void)

    private var observers = [String: PopUpCompletionHandler]()

    @IBOutlet var message: UILabel!
    var handler: PopUpCompletionHandler?
    var labelTitle: String = ""
    var text: String = ""
    var meessageAtributedText: NSMutableAttributedString =  NSMutableAttributedString(string: "")

    var popUpType: PopUpType = .success
    var continueHandler: PopUpCompletionHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        message.textAlignment = .center
        self.message.attributedText = meessageAtributedText
        // Do any additional setup after loading the view.
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
