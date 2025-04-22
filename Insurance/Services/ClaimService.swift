//
//  ClaimService.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import Foundation

protocol ClaimServiceProtocol {
    func fetchClaims() async throws -> [Claim]
    func searchClaims(query: String) async throws -> [Claim]
}

class ClaimService: ClaimServiceProtocol {
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchClaims() async throws -> [Claim] {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let claims = try JSONDecoder().decode([Claim].self, from: data)
            return claims
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func searchClaims(query: String) async throws -> [Claim] {
        let claims = try await fetchClaims()
        
        if query.isEmpty {
            return claims
        }
        
        return claims.filter { claim in
            claim.title.lowercased().contains(query.lowercased()) ||
            claim.body.lowercased().contains(query.lowercased())
        }
    }
}
