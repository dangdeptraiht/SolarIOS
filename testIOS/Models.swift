//
//  Models.swift
//  testIOS
//
//  Created by Dang Nguyen on 8/10/24.
//

import Foundation

struct Section: Codable {
    let category: String
    let contents: [Content]
}

struct Content: Codable {
    let title: String
    let description: String
}
