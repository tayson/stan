//
//  TransactionAPI.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import Foundation

struct TransactionAPI {
    enum HTTPError: Int {
        case inputError = 400
        case accessDenied = 403
        case notFound = 404
        case rateLimited = 429
        case unexpectedError = 500
    }
    
    enum APIError: Error {
        case httpError(HTTPError)
        case unknownError
    }
    
    static let urlString = "https://x8ki-letl-twmt.n7.xano.io/api:O8qF4MsJ/transactions"
    
    private let session = URLSession.shared

    private var url: URL {
        URL(string: Self.urlString)!
    }
    
    private func checkResponse(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknownError }
        
        guard httpResponse.statusCode == 200 else {
            if let httpError = HTTPError(rawValue: httpResponse.statusCode) {
                throw APIError.httpError(httpError)
            } else {
                throw APIError.unknownError
            }
        }
    }
    
    func getTransactions() async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        try checkResponse(response: response)
        return data
    }
    
    func delete(transactionId: Int) async throws {
        var request = URLRequest(url: url.appendingPathComponent("/\(transactionId)"))
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        try checkResponse(response: response)
    }
    
    func post(transactionData: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await session.upload(for: request, from: transactionData)
        try checkResponse(response: response)
        return data
    }
}
