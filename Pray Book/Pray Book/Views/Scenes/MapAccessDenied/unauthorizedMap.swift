//
//  unauthorizedMap.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-11.
//

import SwiftUI
import CoreLocation

struct unauthorizedMap: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Image("dark-background")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            } else {
                Image("light-background")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack{
                Image(systemName: "globe.desk.fill")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 74))
                Text("Allow Location access")
//                Button( action: CLLocationManager().requestWhenInUseAuthorization(), "Allow")
            }

        }
    }
}

#Preview {
    unauthorizedMap()
}
