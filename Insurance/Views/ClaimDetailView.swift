//
//  ClaimDetailView.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import SwiftUI

struct ClaimDetailView: View {
    let claim: Claim
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(claim.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Claim ID: \(claim.id)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Claimant ID: \(claim.userId)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                Text("Description")
                    .font(.headline)
                
                Text(claim.body)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Claim Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
