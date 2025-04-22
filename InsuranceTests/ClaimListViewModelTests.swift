//
//  ClaimListViewModelTests.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import XCTest
@testable import Insurance

class MockClaimService: ClaimServiceProtocol {
    var mockClaims: [Claim] = []
    var shouldThrowError = false
    
    func fetchClaims() async throws -> [Claim] {
        if shouldThrowError {
            throw NetworkError.invalidResponse
        }
        return mockClaims
    }
    
    func searchClaims(query: String) async throws -> [Claim] {
        if shouldThrowError {
            throw NetworkError.invalidResponse
        }
        
        if query.isEmpty {
            return mockClaims
        }
        
        return mockClaims.filter { claim in
            claim.title.lowercased().contains(query.lowercased()) ||
            claim.body.lowercased().contains(query.lowercased())
        }
    }
}

class ClaimsListViewModelTests: XCTestCase {
    var sut: ClaimsListViewModel!
    var mockService: MockClaimService!
    
    override func setUp() {
        super.setUp()
        mockService = MockClaimService()
        sut = ClaimsListViewModel(claimService: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchClaimsSuccess() async {
        // Given
        mockService.mockClaims = [
            Claim(userId: 101, id: 2001, title: "Vehicle damage", body: "Hit from behind at a traffic light..."),
            Claim(userId: 102, id: 2002, title: "Property damage", body: "Roof leak caused water damage to ceiling...")
        ]
        
        // When
        await sut.fetchClaims()
        
        // Then
        XCTAssertEqual(sut.loadingState, .loaded)
        XCTAssertEqual(sut.claims.count, 2)
        XCTAssertEqual(sut.filteredClaims.count, 2)
        XCTAssertEqual(sut.claims[0].id, 2001)
        XCTAssertEqual(sut.claims[1].id, 2002)
    }
    
    func testFetchClaimsFailure() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await sut.fetchClaims()
        
        // Then
        if case .error(let error) = sut.loadingState {
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidResponse)
        } else {
            XCTFail("Expected error state but got \(sut.loadingState)")
        }
        XCTAssertTrue(sut.claims.isEmpty)
    }
    
    func testSearchClaimsSuccess() async {
        // Given
        mockService.mockClaims = [
            Claim(userId: 101, id: 2001, title: "Vehicle damage", body: "Hit from behind at a traffic light..."),
            Claim(userId: 102, id: 2002, title: "Property damage", body: "Roof leak caused water damage to ceiling..."),
            Claim(userId: 103, id: 2003, title: "Medical claim", body: "Hospital visit for broken arm...")
        ]
        await sut.fetchClaims() // Load initial claims
        
        // When
        sut.searchQuery = "vehicle"
        await sut.searchClaims()
        
        // Then
        XCTAssertEqual(sut.filteredClaims.count, 1)
        XCTAssertEqual(sut.filteredClaims[0].id, 2001)
        
        // When searching for "damage" (appears in two claims)
        sut.searchQuery = "damage"
        await sut.searchClaims()
        
        // Then
        XCTAssertEqual(sut.filteredClaims.count, 2)
        
        // When clearing search
        sut.searchQuery = ""
        await sut.searchClaims()
        
        // Then
        XCTAssertEqual(sut.filteredClaims.count, 3)
    }
    
    func testSearchClaimsFailure() async {
        // Given
        mockService.mockClaims = [
            Claim(userId: 101, id: 2001, title: "Vehicle damage", body: "Hit from behind at a traffic light...")
        ]
        await sut.fetchClaims() // Load initial claims
        
        // When
        mockService.shouldThrowError = true
        sut.searchQuery = "vehicle"
        await sut.searchClaims()
        
        // Then
        if case .error(let error) = sut.loadingState {
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidResponse)
        } else {
            XCTFail("Expected error state but got \(sut.loadingState)")
        }
    }
}
