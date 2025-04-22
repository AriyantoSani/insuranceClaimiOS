//
//  ClaimServiceTests.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import XCTest
@testable import Insurance

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = MockURLProtocol.mockResponse {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = MockURLProtocol.mockData {
            self.client?.urlProtocol(self, didLoad: data)
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

class ClaimServiceTests: XCTestCase {
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
    
    func testFetchClaimsSuccess() async throws {
        // Given
        let mockData = """
        [
            {
                "userId": 101,
                "id": 2001,
                "title": "Vehicle damage",
                "body": "Hit from behind at a traffic light..."
            },
            {
                "userId": 102,
                "id": 2002,
                "title": "Property damage",
                "body": "Roof leak caused water damage to ceiling..."
            }
        ]
        """.data(using: .utf8)!
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = response
        
        // When
        let claims = try await sut.fetchClaims()
        
        // Then
        XCTAssertEqual(claims.count, 2)
        XCTAssertEqual(claims[0].id, 2001)
        XCTAssertEqual(claims[0].title, "Vehicle damage")
        XCTAssertEqual(claims[1].id, 2002)
        XCTAssertEqual(claims[1].title, "Property damage")
    }
    
    func testSearchClaimsFiltersCorrectly() async throws {
        // Given
        let mockData = """
        [
            {
                "userId": 101,
                "id": 2001,
                "title": "Vehicle damage",
                "body": "Hit from behind at a traffic light..."
            },
            {
                "userId": 102,
                "id": 2002,
                "title": "Property damage",
                "body": "Roof leak caused water damage to ceiling..."
            }
        ]
        """.data(using: .utf8)!
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = response
        
        // When
        let claims = try await sut.searchClaims(query: "Vehicle")
        
        // Then
        XCTAssertEqual(claims.count, 1)
        XCTAssertEqual(claims[0].id, 2001)
        XCTAssertEqual(claims[0].title, "Vehicle damage")
    }
}
