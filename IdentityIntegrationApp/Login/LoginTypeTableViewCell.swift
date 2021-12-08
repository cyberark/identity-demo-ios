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

class LoginTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var more_button: UIButton!
    @IBOutlet weak var login_button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func configure(){
        more_button.titleLabel?.attributedText = getMoreAttributedText()
    }
    func getMoreAttributedText() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: " Learn More\n")
        let attributes0: [NSAttributedString.Key : Any] = [
           .foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        ]
        attributedString.addAttributes(attributes0, range: NSRange(location: 0, length: 1))
        let attributes1: [NSAttributedString.Key : Any] = [
           .foregroundColor: UIColor(red: 5/255, green: 99/255, blue: 193/255, alpha: 1.0)
        ]
        attributedString.addAttributes(attributes1, range: NSRange(location: 1, length: 10))
        return attributedString
    }
}
