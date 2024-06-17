//
//  viewallPrayers.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-05.
//

import SwiftUI
import SwiftData

struct viewallPrayers: View {
    @Environment(\.modelContext) var modelContext
    @Query var prayer: [Prayers]
    var body: some View {
        List {
            ForEach(prayer) { prayer in
                NavigationLink(value: prayer) {
                    Text(prayer.title).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
            }
//            .onDelete(perform: deletePeople)
        }
    }
}

#Preview {
    viewallPrayers()
}
