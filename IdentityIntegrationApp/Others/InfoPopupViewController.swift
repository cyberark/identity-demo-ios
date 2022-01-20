//
//  InfoPopupViewController.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 20/01/22.
//

import UIKit

class InfoPopupViewController: UIViewController {
    
    typealias PopUpCompletionHandler = (() -> Void)

    private var observers = [String: PopUpCompletionHandler]()

    @IBOutlet var message_textview: UILabel!

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
        message_textview.isUserInteractionEnabled = true
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
