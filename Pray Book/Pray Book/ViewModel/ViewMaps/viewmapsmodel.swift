//
//  viewmapsmodel.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-09.
//

import SwiftUI
import SwiftData

struct viewmapsmodel: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query var maps: [Maps]
    
    var truncatedTitle: (String) ->  String = {
        title in
        let words = title.split(separator: " ")
        let truncated = words.prefix(10)
        return truncated.joined(separator: " ")
    }
    
    var body: some View {
        if maps.isEmpty {
            Image("nocontent_found")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .frame(width: 250, height: 200)
                .padding()
        }else {
            List {
                ForEach(maps) { map in
                    NavigationLink(destination: oneMapView(map: map)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(truncatedTitle(map.title))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            Spacer()
                            Text(map.city)
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .padding()
                        
                    }
                    .cornerRadius(20)
                }
                .onDelete(perform: deleteMap)
            }
            .padding()
            .cornerRadius(20)
        }
    }
    init(searchString: String = "", sortOrder: [SortDescriptor<Maps>] = []) {
        _maps = Query(filter: #Predicate { map in
            if searchString.isEmpty {
                true
            } else {
                map.title.localizedStandardContains(searchString) ||
                map.city.localizedStandardContains(searchString)
            }
        }, sort: sortOrder)
    }
    
    //delete map function
    func deleteMap(at offsets: IndexSet) {
        for offset in offsets {
            let map = maps[offset]
            modelContext.delete(map)
        }
    }
}
#Preview {
    viewmapsmodel()
}
