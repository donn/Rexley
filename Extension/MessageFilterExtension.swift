//
//  MessageFilterExtension.swift
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

import IdentityLookup
import Regex

final class MessageFilterExtension: ILMessageFilterExtension, ILMessageFilterQueryHandling {

    func handle(
        _ queryRequest: ILMessageFilterQueryRequest,
        context: ILMessageFilterExtensionContext,
        completion: @escaping (ILMessageFilterQueryResponse) -> Void
    ) {
        let offlineAction = self.offlineAction(for: queryRequest)
        let response = ILMessageFilterQueryResponse()
        response.action = offlineAction
        completion(response)
    }

    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        // Replace with logic to perform offline check whether to filter first (if possible).
        let sender = queryRequest.sender ?? "", messageBody = queryRequest.messageBody ?? ""
        let filterList = UserDefaults.group.getCodable(forKey: "RegexList", using: [Filter].self) ?? []
        
        
        for filter in filterList {
            let comparedField = filter.field == .sender ? sender : filter.field == .messageBody ? messageBody : sender + "\n" + messageBody
            
            if comparedField == "" || comparedField == "\n" {
                continue
            }
            
            guard let pattern = filter.pattern else {
                continue
            }
            
            if (filter.regex) {
                let regexOptions: RegexOptions = filter.caseSensitive ? [] : [.caseInsensitive]
                do {
                    let regex = try Regex(pattern: pattern, options: regexOptions)
                    if comparedField =~ regex {
                        return filter.action
                    }
                } catch {
                    NSLog("CRITICAL: Failed to compile regex '\(pattern)'")
                    continue
                }
            } else {
                
                let comparedFieldCasing = filter.caseSensitive ? comparedField : comparedField.lowercased()
                let patternCasing = filter.caseSensitive ? pattern : pattern.lowercased()
                
                if comparedFieldCasing.contains(patternCasing) {
                    return filter.action
                }
            }
        }
        
        
        return .allow
    }

    private func action(for networkResponse: ILNetworkResponse) -> ILMessageFilterAction {
        // Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return .none
    }

}
