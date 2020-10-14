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

enum GlobalConstants: String {
    case appGroup = "group.website.donn.Rexley-Spam-Blocker"
    case iap1 = "website.donn.Rexley_Tip_1DOLLAR"
    case iap3 = "website.donn.Rexley_Tip_3DOLLAR"
    case iap5 = "website.donn.Rexley_Tip_5DOLLAR"
}

extension UserDefaults {
    static let group = UserDefaults(suiteName: GlobalConstants.appGroup.rawValue)!
    
    func getCodable<T: Codable>(forKey key: String, using type: T.Type) -> T? {
        guard let marshalled = self.string(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: marshalled.data(using: .utf8)!) else {
            return nil
        }
        return decoded
    }
    
    func setCodable<T: Codable>(_ object: T, forKey key: String) -> T? {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(object) else {
            return nil
        }
        guard let string = String(data: encoded, encoding: .utf8) else {
            return nil
        }
        self.set(string, forKey: key)
        return object
    }
}

extension Array { // Queue
    mutating func push(_ el: Element) {
        self.append(el)
    }
    func peek() -> Element? {
        return self.first
    }
    mutating func pop() -> Element? {
        if self.count > 0 {
            return self.removeFirst()
        }
        return nil
    }
}

