
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

import Foundation
import UIKit
public extension String {
    /// Encode the string
    /// - Returns: encoded string
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    /// Decodes the String
    /// - Returns: the decoded string
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
    public func toData() -> Data? {
        return self.data(using: .utf8)
    }
}
public extension String {
    var isValidURL: Bool {
        var isValid = false
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            isValid =  match.range.length == self.utf16.count
        } else {
            isValid = false
        }
        return isValid
    }
}
extension String {
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> Data? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return data
    }
}
public extension String {
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    func fetchAttributedTextContent(firstText:String, firstTintColor:UIColor, secondText:String, secondTintColor:UIColor) -> NSMutableAttributedString {
        
        let firstAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: firstTintColor]
        let secondtAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: secondTintColor]
        let partOne = NSMutableAttributedString(string: firstText, attributes: firstAttribute as [NSAttributedString.Key : Any])
        let partTwo = NSMutableAttributedString(string: secondText, attributes: secondtAttribute as [NSAttributedString.Key : Any])
        partOne.append(partTwo)
        return partOne
    }
    func fetchAttributedTextContentWithParagraphStyle(firstText:String, firstTintColor:UIColor, secondText:String, secondTintColor:UIColor) -> NSMutableAttributedString {
        
        let firstAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: firstTintColor]
        let secondtAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: secondTintColor]
        let partOne = NSMutableAttributedString(string: firstText, attributes: firstAttribute as [NSAttributedString.Key : Any])
        let partTwo = NSMutableAttributedString(string: secondText, attributes: secondtAttribute as [NSAttributedString.Key : Any])
        partOne.append(partTwo)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.33
        let paragraphAtributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let range = partOne.mutableString.range(of: partOne.string, options: .caseInsensitive)
        partOne.addAttributes(paragraphAtributes, range: range)
        return partOne
    }
    func getLinkAttributes(header: String, linkAttribute: String, headerFont : UIFont ,textFont : UIFont , color: UIColor, underLineColor: UIColor, linkValue: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        let paragraphAtributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        attributedString.addAttributes(paragraphAtributes, range:  NSRange(location: 0, length: self.count))

        let selfAttributes = [[NSAttributedString.Key.font: textFont],[NSAttributedString.Key.foregroundColor: UIColor.white]]
        
        for attribute in selfAttributes {
            attributedString.addAttributes(attribute, range: NSRange(location: 0, length: self.count))
        }
        
        let headerAttributes = [[NSAttributedString.Key.font:headerFont],[NSAttributedString.Key.foregroundColor: color]]
        let headerRange = (self as NSString).range(of: header)
        for attribute in headerAttributes {
            attributedString.addAttributes(attribute, range: headerRange)
        }
        
        let range = (self as NSString).range(of: linkAttribute)
        let attributes = [[NSAttributedString.Key.font: textFont], [NSAttributedString.Key.foregroundColor: color],        [.underlineStyle: NSUnderlineStyle.single.rawValue]]
        attributedString.addAttribute(.link, value: linkValue, range: range)
        for attribute in attributes {
            attributedString.addAttributes(attribute, range: range)
        }
        return attributedString
    }
}
