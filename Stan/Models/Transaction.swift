//
//  Transaction.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import Foundation

struct Transaction: Codable, Hashable {
    enum Kind: String, Codable {
        case income
        case expense
    }
    
    let id: Int?
    let createdAt: Date?
    let type: Kind
    let amount: Double
    
    init(id: Int? = nil, createdAt: Date? = nil, type: Kind, amount: Double) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.amount = amount
    }
    
    var day: Date {
        guard let createdAt else { return Date() }
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month, .day], from: createdAt)
        return cal.date(from: components)!
    }
}
