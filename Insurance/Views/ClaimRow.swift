//
//  ClaimRow.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import SwiftUI

struct ClaimRow: View {
    let claim: Claim
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(claim.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Text(claim.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("Claim ID: \(claim.id)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Claimant ID: \(claim.userId)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}
