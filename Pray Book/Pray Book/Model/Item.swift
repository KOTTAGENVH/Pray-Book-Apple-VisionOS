//
//  Item.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-02.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var desc: String
    var imageData: Data?
    var timestamp: Date
    
    init(title: String, desc: String, imageData: Data? = nil, timestamp: Date) {
        self.title = title
        self.desc = desc
        self.imageData = imageData
        self.timestamp = timestamp
    }
}
