//
//  ModelStore.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import Foundation
import CoreData

@MainActor class ModelStore: ObservableObject {
    enum ModelStoreError: Error {
        case invalidTransactionId
    }
    
    @Published private(set) var transactions: [Transaction] = []
    
    private let api = TransactionAPI()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func refreshTransactions() async throws {
        let data = try await api.getTransactions()
        self.transactions = try jsonDecoder.decode([Transaction].self, from: data)
    }
    
    func delete(transaction: Transaction) async throws {
        guard let transactionId = transaction.id else {
            throw ModelStoreError.invalidTransactionId
        }
        try await api.delete(transactionId: transactionId)
        self.transactions.removeAll(where: {$0.id == transaction.id})
    }
    
    func add(transaction: Transaction) async throws {
        let transactionData = try jsonEncoder.encode(transaction)

        let data = try await api.post(transactionData: transactionData)
        let updatedTransaction = try jsonDecoder.decode(Transaction.self, from: data)

        self.transactions.append(updatedTransaction)
    }
    
    func transactions(startDate: Date, endDate: Date, type: Transaction.Kind? = nil) -> [Transaction] {
        transactions.filter {
            guard let date = $0.createdAt else { return false }
            if let type {
                return date >= startDate && date <= endDate && $0.type == type
            } else {
                return date >= startDate && date <= endDate
            }
        }
    }
    
    func balance(startDate: Date, endDate: Date) -> Double {
        transactions(startDate: startDate, endDate: endDate)
        .reduce(0.0) {
            switch $1.type {
            case .expense: return $0 - $1.amount
            case .income: return $0 + $1.amount
            }
        }
    }
    
    func income(startDate: Date, endDate: Date) -> Double {
        transactions(startDate: startDate, endDate: endDate, type: .income)
        .reduce(0.0) {
            return $0 + $1.amount
        }
    }
    
    func expenses(startDate: Date, endDate: Date) -> Double {
        transactions(startDate: startDate, endDate: endDate, type: .expense)
        .reduce(0.0) {
            return $0 + $1.amount
        }
    }
}
