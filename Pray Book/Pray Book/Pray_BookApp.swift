//
//  Pray_BookApp.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-02.
//

import SwiftUI
import SwiftData

@main
struct Pray_BookApp: App {
//    var prayerModelContainer: ModelContainer = {
//        let schema = Schema([
//            Prayers.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        do {
//            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//            print("Prayer ModelContainer successfully created.")
//            return container
//        } catch {
//            print("Failed to create ModelContainer Prayer: \(error)")
//            fatalError("Could not create ModelContainer Prayer: \(error)")
//        }
//    }()
//    
//    var mapModelContainer: ModelContainer = {
//        let schema = Schema([
//            Maps.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        do {
//            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//            print("Maps ModelContainer successfully created.")
//            return container
//        } catch {
//            print("Failed to create ModelContainer Maps: \(error)")
//            fatalError("Could not create ModelContainer Maps: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Prayers.self, Maps.self])
    }
}
