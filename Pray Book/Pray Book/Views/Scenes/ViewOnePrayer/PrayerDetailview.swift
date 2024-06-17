//
//  PrayerDetailview.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-06.
//

import SwiftUI
import AVFoundation

//Prayer Detail View
struct PrayerDetailview: View {
    @Environment(\.colorScheme) var colorScheme
    let prayer: Prayers
    
    @State private var offset = CGSize.zero
    @State  var currentLineIndex = 0
    @State private var isFullScreen = false
    @State private var textSize: CGFloat = 20
    
    
    var body: some View {
        GeometryReader { geometry in
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
                
                VStack {
                    if(!isFullScreen){
                        HStack {
                            if let imageData = prayer.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding()
                            } else {
                                Image("no-image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding()
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                    VStack {
                        HStack {
                            HStack {
                                Button(action: increaseSize) {
                                    Image(systemName: "plus")
                                        .font(.system(size: isFullScreen ? 30 : 20))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                .padding(isFullScreen ? 5 : 10)
                                Button(action: decreaseSize) {
                                    Image(systemName: "minus")
                                        .font(.system(size: isFullScreen ? 30 : 20))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                .padding(isFullScreen ? 5 : 10)
                                
                            }
                            Spacer()
                            Button(action: {
                                copyPrayer(description: prayer.desc)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: isFullScreen ? 30 : 20))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .padding(isFullScreen ? 5 : 10)
                            HStack {
                                if(!isFullScreen){
                                    Button(action: fullscreen) {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .font(.system(size: isFullScreen ? 30 : 20))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                    .padding(isFullScreen ? 5 : 10)
                                }else {
                                    Button(action: originalscreen) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: isFullScreen ? 30 : 20))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                    .padding(isFullScreen ? 5 : 10)
                                }
                                
                                
                            }
                            
                        }
                        .padding()
                        ScrollView {
                            Text(prayer.desc)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: textSize))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                        
                    }
                    .background(colorScheme == .dark ? Color.gray : Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: offset.height)
                }
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(prayer.title)
            .font(.title3)
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: editPrayer(prayer: prayer)) {
                        Image(systemName: "pencil")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 24))
                            .padding()
                    }
            )
        }
        
    }
    
    //font size altercation
    func increaseSize() {
        textSize += 2
    }
    
    func decreaseSize() {
        textSize -= 2
        textSize = max(textSize, 10)
    }
    
    //Screen toggles
    func fullscreen() {
        isFullScreen = true
    }
    
    func originalscreen() {
        isFullScreen = false
    }
    
    //copy prayer function
    func copyPrayer(description: String) -> Void {
        let pasteboard = UIPasteboard.general
        pasteboard.string = description
    }
    
    
    //spotify current speak highlight(discontinued)
    func colorForLine(_ line: String) -> Color {
        print("Current index\(currentLineIndex)")
        let lines = prayer.desc.components(separatedBy: "\n")
        guard let currentIndex = lines.firstIndex(of: line) else {
            return colorScheme == .dark ? .white : .black
        }
        return currentIndex == currentLineIndex ? (colorScheme == .dark ? .black : .white) : (colorScheme == .dark ? .white : .black)
    }
    
}

struct PrayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePrayer = Prayers(title: "Sample Prayer", desc: "This is a sample prayer description.", timestamp: Date())
        return PrayerDetailview(prayer: samplePrayer)
    }
}
