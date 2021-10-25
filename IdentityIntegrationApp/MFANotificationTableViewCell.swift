//
//  MFANotificationTableViewCell.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 08/10/21.
//

import UIKit

class MFANotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var text_label: UILabel!

    @IBOutlet weak var approve_button: UIButton!
    @IBOutlet weak var reject_button: UIButton!
    
    @IBAction func approve_click(_ sender: Any) {
    }
    
    @IBAction func reject_click(_ sender: Any) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
