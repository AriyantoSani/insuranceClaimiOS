//
//  ClaimListView.swift
//  Insurance
//
//  Created by Ariyanto Sani on 22/04/25.
//

import SwiftUI

struct ClaimsListView: View {
    @StateObject private var viewModel = ClaimsListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.loadingState {
                case .idle, .loading:
                    ProgressView("Loading claims...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                case .loaded:
                    List(viewModel.filteredClaims) { claim in
                        NavigationLink(destination: ClaimDetailView(claim: claim)) {
                            ClaimRow(claim: claim)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, prompt: "Search claims")
                    .onChange(of: searchText) { newValue in
                        viewModel.searchQuery = newValue
                        Task {
                            await viewModel.searchClaims()
                        }
                    }
                
                case .error(let error):
                    VStack {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchClaims()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Insurance Claims")
        }
        .task {
            await viewModel.fetchClaims()
        }
    }
}
