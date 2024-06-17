//
//  arView.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-08.
//

import SwiftUI
import RealityKit

struct ARImageView: View {
    let prayer: Prayers
    let arView: ARView
    
    var body: some View {
        ARViewContainer(arView: arView, prayer: prayer)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView: ARView
    let prayer: Prayers
    
    init(arView: ARView, prayer: Prayers) {
        self.arView = arView
        self.prayer = prayer
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = self.arView
        
        if let imageData = prayer.imageData, let uiImage = UIImage(data: imageData) {
            let imageAnchor = AnchorEntity(plane: .horizontal)
            let imageEntity = ModelEntity(mesh: .generatePlane(width: 1, height: 1), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
            imageAnchor.addChild(imageEntity)
            arView.scene.addAnchor(imageAnchor)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePrayer = Prayers(title: "Sample Prayer", desc: "This is a sample prayer description.", timestamp: Date())
        let arView = ARView(frame: .zero)
        return ARImageView(prayer: samplePrayer, arView: arView)
    }
}


