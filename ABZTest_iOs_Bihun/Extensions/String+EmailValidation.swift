//
//  File.swift
//  ABZTest_iOs_Bihun
//
//  Created by Roman Bigun on 21.06.2025.
//

import SwiftUI

extension String {
    // MARK: - email validation according to RFC2822
    func isEmailValid() -> Bool {
        let emailRegexPattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"

            do {
                let regex = try Regex(emailRegexPattern)
                return self.wholeMatch(of: regex) != nil
            } catch {
                print("Error creating regex: \(error)")
                return false // Handle regex compilation error
            }
     }
}
