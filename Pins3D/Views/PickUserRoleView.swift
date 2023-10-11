//
//  ContentView.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/10/23.
//

import SwiftUI

struct PickUserRoleView: View {
    // Define an enum for our navigation state
    enum NavigationTarget {
        case first
        case second
    }

    // State to determine which detail view to show
    @State private var navigationTarget: NavigationTarget? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: CatalogView(title: "All Modules")) {
                    Text("Producer Role")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: FirstDetailView()) {
                    Text("Consumer Role")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
