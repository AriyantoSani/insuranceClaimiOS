//
//  NetworkErrorTests.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import XCTest
@testable import Insurance

class NetworkErrorTests: XCTestCase {
    
    func testNetworkErrorDescriptions() {
        // Given
        let invalidURLError = NetworkError.invalidURL
        let invalidResponseError = NetworkError.invalidResponse
        let httpError = NetworkError.httpError(statusCode: 404)
        let decodingError = NetworkError.decodingError(NSError(domain: "test", code: 1))
        let unknownError = NetworkError.unknown(NSError(domain: "test", code: 2))
        
        // Then
        XCTAssertEqual(invalidURLError.errorDescription, "Invalid URL")
        XCTAssertEqual(invalidResponseError.errorDescription, "Invalid response")
        XCTAssertEqual(httpError.errorDescription, "HTTP error: 404")
        XCTAssertTrue(decodingError.errorDescription?.contains("Failed to decode") ?? false)
        XCTAssertTrue(unknownError.errorDescription?.contains("Unknown error") ?? false)
    }
}
