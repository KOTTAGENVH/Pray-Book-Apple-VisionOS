//
//  Prayers.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-05.
//

import Foundation
import SwiftData
import SwiftUI

//Model for Prayers
@Model
class Prayers {
    var title: String
    var desc: String
    @Attribute(.externalStorage) var imageData: Data?
    var timestamp: Date
    
    init(title: String, desc: String, timestamp: Date) {
        self.title = title
        self.desc = desc
        self.timestamp = timestamp
    }
}
