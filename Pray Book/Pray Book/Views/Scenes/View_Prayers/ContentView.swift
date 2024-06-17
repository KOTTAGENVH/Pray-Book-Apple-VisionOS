//
//  ContentView.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-02.
//

import SwiftUI
import SwiftData

// Home screen
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @State private var path = NavigationPath()
    @State private var sortOrder = [SortDescriptor(\Prayers.timestamp)]
    @State private var searchText = ""

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)

                AllPrayerViewModal(searchString: searchText, sortOrder: sortOrder)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .navigationBarTitle("Home", displayMode: .inline)
                    .font(.title2)
                    .searchable(text: $searchText)
                    .padding(0.2)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        HStack {
                            NavigationLink(destination: allMaps()) {
                                Image(systemName: "map")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .accessibility(identifier: "map")
                            .padding(.bottom, 20)
                            Spacer()
                            NavigationLink(destination: addPrayer()) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                            .accessibility(identifier: "plus")
                            .padding(.bottom, 20)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
