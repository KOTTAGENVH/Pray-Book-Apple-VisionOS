//
//  AllPrayerViewModal.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-06.
//

import SwiftUI
import SwiftData

struct AllPrayerViewModal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query var prayers: [Prayers]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var truncatedTitle: (String) -> String = {
        title in
        let truncated = title.prefix(10)
        return String(truncated)
    }
    
    
    
    var body: some View {
        if prayers.isEmpty {
            Image("nocontent_found")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .frame(width: 250, height: 200)
                .padding()
                .accessibility(identifier: "NoContentImage")
        } else {
            List {
                ForEach(prayers) { prayer in
                    NavigationLink(destination: PrayerDetailview(prayer: prayer)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(truncatedTitle(prayer.title))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            Spacer()
                            Text(dateFormatter.string(from: prayer.timestamp))
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .padding()
                        .cornerRadius(20)
                    }
                    .cornerRadius(20)
                }
                .onDelete(perform: deletePrayer)
            }
            .padding()
            .cornerRadius(20)
        }
    }
    init(searchString: String = "", sortOrder: [SortDescriptor<Prayers>] = []) {
        _prayers = Query(filter: #Predicate { prayer in
            if searchString.isEmpty {
                true
            } else {
                prayer.title.localizedStandardContains(searchString) ||
                prayer.desc.localizedStandardContains(searchString)
            }
        }, sort: sortOrder)
    }
    
    //delete Prayer
    func deletePrayer(at offsets: IndexSet) {
        for offset in offsets {
            let prayer = prayers[offset]
            modelContext.delete(prayer)
        }
    }
}

#Preview {
    AllPrayerViewModal()
}

