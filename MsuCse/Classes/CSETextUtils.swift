//
//  CSETextUtils.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation


internal class CSETextUtils {
    static func hasAnyPrefix(_ number: String?, prefixes: [String]) -> Bool {
        guard let number = number else {
            return false
        }
        
        for prefix in prefixes {
            if number.starts(with: prefix) {
                return true
            }
        }
        
        return false
    }
}
