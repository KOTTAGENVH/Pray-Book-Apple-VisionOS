//
//  editPrayer.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-07.
//

import SwiftUI
import PhotosUI

//Edit Prayer
struct editPrayer: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var uploadItem: PhotosPickerItem?
    @State private var uploadedUIImage: UIImage?
    @State private var uploadedimage: Image?
    @State private var showingPhotoPicker = false
    @State private var isTitleEmpty: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    @Bindable var prayer: Prayers
    
    init(prayer: Prayers) {
        self.prayer = prayer
        _uploadedimage = State(initialValue: nil)
    }
    
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
                                text: $prayer.title
                            )
                            .textFieldStyle(PaddedTextFieldStyleTitle())
                            .padding()
                            .onChange(of: prayer.title) { newValue in
                                if !newValue.isEmpty {
                                    isTitleEmpty = false
                                    saveChanges()
                                }
                            }
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
                            PaddedTextEditor(text: $prayer.desc, height: 200, frameheight: 208)
                                .onChange(of: prayer.desc) { _ in
                                    saveChanges()
                                }
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
                                if let imageData = prayer.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
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
                        }
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
                                    saveChanges()
                                }
                            }
                        }
                        
                        HStack {
                            Button("Done") {
                                handleDone()
                            }
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
                    ProgressView("Updating...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .navigationBarTitle("Edit Prayer", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: handleDone) {
                        Image(systemName: "checkmark")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding()
                    }
                
            )
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    //photoPicker trigger
    private func showPhotoPicker() {
        showingPhotoPicker = true
    }
    
    //hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //Save changes
    private func saveChanges() {
        isLoading = true
        
        // Convert UIImage to Data and update the prayer object
        if let uploadedUIImage = uploadedUIImage {
            prayer.imageData = uploadedUIImage.jpegData(compressionQuality: 1.0)
        }
        
        do {
            try modelContext.save()
            isLoading = false
        } catch {
            showAlert = true
            alertMessage = "Failed to save prayer"
            print("Failed to save prayer: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    //handle validation
    private func handleDone() {
        if prayer.title.isEmpty {
            isTitleEmpty = true
        } else {
            saveChanges()
            dismiss()
        }
    }
    
}

struct editPrayerView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePrayer = Prayers(title: "Sample Prayer", desc: "This is a sample prayer description.", timestamp: Date())
        return editPrayer(prayer: samplePrayer)
    }
}
