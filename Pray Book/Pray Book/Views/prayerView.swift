//
//  prayerView.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-05.
//

import SwiftData
import SwiftUI

struct prayerView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var prayer: [Prayers]
    
    var body: some View {
        List {
            ForEach(prayer) { prayer in
                NavigationLink(value: prayer) {
                    Text(prayer.title)
                }
            }
            .onDelete(perform: deletePeople)
        }
    }
    
    init(searchString: String = "", sortOrder: [SortDescriptor<Prayers>] = []) {
        _prayer = Query(filter: #Predicate { prayer in
            searchString.isEmpty ||
            prayer.title.localizedStandardContains(searchString) ||
            prayer.desc.localizedStandardContains(searchString)
        }, sort: sortOrder)
    }

    
    func deletePeople(at offsets: IndexSet) {
        for offset in offsets {
            let prayer = prayer[offset]
            modelContext.delete(prayer)
        }
    }
}
#Preview {
    prayerView()
}
