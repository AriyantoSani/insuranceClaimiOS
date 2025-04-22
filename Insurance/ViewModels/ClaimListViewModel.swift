//
//  ClaimListViewModel.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import Foundation
import SwiftUI

enum LoadingState {
    case idle
    case loading
    case loaded
    case error(NetworkError)
}

class ClaimsListViewModel: ObservableObject {
    @Published var claims: [Claim] = []
    @Published var filteredClaims: [Claim] = []
    @Published var searchQuery: String = ""
    @Published var loadingState: LoadingState = .idle
    
    private let claimService: ClaimServiceProtocol
    
    init(claimService: ClaimServiceProtocol = ClaimService()) {
        self.claimService = claimService
    }
    
    @MainActor
    func fetchClaims() async {
        loadingState = .loading
        
        do {
            claims = try await claimService.fetchClaims()
            filteredClaims = claims
            loadingState = .loaded
        } catch let error as NetworkError {
            loadingState = .error(error)
        } catch {
            loadingState = .error(.unknown(error))
        }
    }
    
    @MainActor
    func searchClaims() async {
        do {
            filteredClaims = try await claimService.searchClaims(query: searchQuery)
        } catch let error as NetworkError {
            loadingState = .error(error)
        } catch {
            loadingState = .error(.unknown(error))
        }
    }
}
