
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

public extension Date {
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
}
public extension Date {
    func epirationDate(with timestamp: Int) -> Date {
        let date = self.addingTimeInterval(TimeInterval(timestamp))
        return date
    }
}

public extension Date {
    
    func isAccessTokenExpired(with token: Data?) -> Bool {
        guard let data = token else {
            return false
        }
        var expirationDate = data.to(type: Date.self)
        //expirationDate = expirationDate.addingTimeInterval(-10*60)
        if self.isGreaterThan(expirationDate) {
            return true
        }
        return false
        
    }
}
public extension Date {
    
    func getCurrentMillis()->Int{
        return  Int(NSDate().timeIntervalSince1970 * 1000)
    }

}
