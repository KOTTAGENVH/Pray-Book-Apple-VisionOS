//
//  addPrayer.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-02.
//

import SwiftUI
import PhotosUI

struct addPrayer: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var title: String = ""
    @State var prayerdesc: String = ""
    @State private var uploadItem: PhotosPickerItem?
    @State private var uploadedUIImage: UIImage?
    @State private var uploadedimage: Image?
    @State private var showingPhotoPicker = false
    @State private var navigateToPrayerView = false
    @State private var isTitleEmpty: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .dark {
                    Image("dark-background")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            hideKeyboard()
                        }
                } else {
                    Image("light-background")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
                
                ScrollView {
                    VStack {
                        HStack {
                            Text("Title:")
                                .foregroundColor(.primary)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                            
                            TextField(
                                "Prayer Name",
                                text: $title
                            )
                            .textFieldStyle(PaddedTextFieldStyleTitle())
                            .padding()
                        }
                        .padding()
                        // Warning text for empty title
                        if isTitleEmpty {
                            Text("Title is required")
                                .foregroundColor(.red)
                                .padding(.bottom, 8)
                        }
                        
                        HStack {
                            Text("Prayer:")
                                .foregroundColor(.primary)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            PaddedTextEditor(text: $prayerdesc, height: 200, frameheight: 208)
                        }
                        .padding()
                        
                        HStack {
                            if let uploadedimage = uploadedimage {
                                uploadedimage
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .frame(width: 300, height: 200)
                            } else {
                                Image("no-image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .frame(width: 300, height: 200)
                            }
                        }
                        .accessibility(identifier: "AddPrayerImage")
                        .padding()
                        .onTapGesture {
                            showPhotoPicker()
                        }
                        .photosPicker(isPresented: $showingPhotoPicker, selection: $uploadItem, matching: .images)
                        .onChange(of: uploadItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    uploadedUIImage = uiImage
                                    uploadedimage = Image(uiImage: uiImage)
                                }
                            }
                        }
                        
                        HStack {
                            Button("Save", action: save)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.buttoncustom1)
                        .cornerRadius(8)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Saving...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .navigationBarTitle("Add Prayer", displayMode: .inline)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    //Change the state to display photo picker
    private func showPhotoPicker() {
        showingPhotoPicker = true
    }
    
    //Hide keyboard function
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Function to save the data
    func save() {
        guard !title.isEmpty else {
            isTitleEmpty = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isTitleEmpty = false
            }
            return
        }
        
        isLoading = true
        
        // Convert UIImage to Data
        let imageData: Data? = uploadedUIImage?.jpegData(compressionQuality: 1.0)
        
        let prayer = Prayers(title: title, desc: prayerdesc, timestamp: Date())
        prayer.imageData = imageData
        modelContext.insert(prayer)
        do {
            try modelContext.save()
            // Set flag to navigate back to the content view
            isLoading = false
            dismiss()
        } catch {
            showAlert = true
            alertMessage = "Failed to save prayer"
            print("Failed to save prayer: \(error.localizedDescription)")
            isLoading = false
        }
    }
}

#Preview {
    addPrayer()
}
