//
//  UITextField+MaxLen.swift
//  NISdk
//
//  Created by Johnny Peter on 22/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation

extension UITextField {
    func hasReachedCharacterLimit(for string: String, in range: NSRange, with limit: Int) -> Bool {
        let currentCharacterCount = text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= limit
    }
}
