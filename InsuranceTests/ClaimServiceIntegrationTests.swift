//
//  ClaimServiceIntegrationTests.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import XCTest
@testable import Insurance

class ClaimServiceIntegrationTests: XCTestCase {
    var sut: ClaimService!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        
        sut = ClaimService()
    }
    
    override func tearDown() {
        sut = nil
        session = nil
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        
        super.tearDown()
    }
    
    func testFetchClaimsHTTPError() async {
        // Given
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = Data()
        
        // When/Then
        do {
            _ = try await sut.fetchClaims()
            XCTFail("Expected HTTP error but got success")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.httpError(statusCode: 404))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testFetchClaimsDecodingError() async {
        // Given
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = "Invalid JSON".data(using: .utf8)
        
        // When/Then
        do {
            _ = try await sut.fetchClaims()
            XCTFail("Expected decoding error but got success")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Expected decodingError but got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testSearchClaimsWithEmptyQuery() async throws {
        // Given
        let mockData = """
        [
            {"userId": 101, "id": 2001, "title": "Vehicle damage", "body": "Hit from behind at a traffic light..."},
            {"userId": 102, "id": 2002, "title": "Property damage", "body": "Roof leak caused water damage to ceiling..."}
        ]
        """.data(using: .utf8)!
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = mockData
        
        // When
        let claims = try await sut.searchClaims(query: "")
        
        // Then
        XCTAssertEqual(claims.count, 2)
    }
    
    func testSearchClaimsWithMatchingQuery() async throws {
        // Given
        let mockData = """
        [
            {"userId": 101, "id": 2001, "title": "Vehicle damage", "body": "Hit from behind at a traffic light..."},
            {"userId": 102, "id": 2002, "title": "Property damage", "body": "Roof leak caused water damage to ceiling..."}
        ]
        """.data(using: .utf8)!
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = mockData
        
        // When
        let claims = try await sut.searchClaims(query: "vehicle")
        
        // Then
        XCTAssertEqual(claims.count, 1)
        XCTAssertEqual(claims[0].id, 2001)
    }
}
