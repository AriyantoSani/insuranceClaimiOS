//
//  ClaimModelTests.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import XCTest
@testable import Insurance

class ClaimModelTests: XCTestCase {
    
    func testClaimDecoding() throws {
        // Given
        let json = """
        {
            "userId": 101,
            "id": 2001,
            "title": "Vehicle damage",
            "body": "Hit from behind at a traffic light..."
        }
        """.data(using: .utf8)!
        
        // When
        let claim = try JSONDecoder().decode(Claim.self, from: json)
        
        // Then
        XCTAssertEqual(claim.userId, 101)
        XCTAssertEqual(claim.id, 2001)
        XCTAssertEqual(claim.title, "Vehicle damage")
        XCTAssertEqual(claim.body, "Hit from behind at a traffic light...")
    }
    
    func testClaimEquality() {
        // Given
        let claim1 = Claim(userId: 101, id: 2001, title: "Vehicle damage", body: "Description 1")
        let claim2 = Claim(userId: 101, id: 2001, title: "Vehicle damage", body: "Description 1")
        let claim3 = Claim(userId: 102, id: 2002, title: "Property damage", body: "Description 2")
        
        // Then
        XCTAssertEqual(claim1, claim2)
        XCTAssertNotEqual(claim1, claim3)
        
        // Test that equality is based on ID, not content
        let claim4 = Claim(userId: 101, id: 2001, title: "Different title", body: "Different body")
        XCTAssertEqual(claim1, claim4)
    }
}
