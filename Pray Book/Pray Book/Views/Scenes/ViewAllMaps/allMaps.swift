//
//  allMaps.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-09.
//

import SwiftUI
import SwiftData

//View All Maps
struct allMaps: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @State private var path = NavigationPath()
    @State private var sortOrder = [SortDescriptor(\Maps.city)]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                
                viewmapsmodel(searchString: searchText, sortOrder: sortOrder)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: addLocation()) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .navigationBarTitle("Spiritual Site Memorizer", displayMode: .inline)
            .font(.title2)
            .searchable(text: $searchText)
            .padding(0.2)
        }
    }
}

#Preview {
    allMaps()
}
