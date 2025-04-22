//
//  ClaimModels.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import Foundation

struct Claim: Identifiable, Codable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    
    static func == (lhs: Claim, rhs: Claim) -> Bool {
        return lhs.id == rhs.id
    }
}
