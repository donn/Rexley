//
//  Filter.swift
//  Rexley Spam Blocker
//
//  Copyright © 2020 Mohamed Gaber. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import IdentityLookup

enum Field: String, Codable {
    case sender = "sender"
    case messageBody = "messageBody"
}

extension ILMessageFilterAction: Codable {}

class Filter: Codable {
    var pattern: String?
    var field: Field?
    var caseSensitive: Bool
    var regex: Bool
    var action: ILMessageFilterAction
    
    init(pattern: String?, field: Field? = nil, caseSensitive: Bool = true, regex: Bool = false, action: ILMessageFilterAction = .junk) {
        
        self.pattern = pattern
        self.field = field
        self.caseSensitive = caseSensitive
        self.regex = regex
        self.action = action
    }
}
