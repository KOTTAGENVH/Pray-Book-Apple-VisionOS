//
//  customComponents.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-07.
//

import SwiftUI
import MapKit

// Custom Text Field for title
struct PaddedTextFieldStyleTitle: TextFieldStyle {
    var height: CGFloat = 40
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .frame(height: height)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
    }
}

//Custom text editor
struct PaddedTextEditor: View {
    @Binding var text: String
    var height: CGFloat
    var frameheight: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
                .frame(height: frameheight)
            TextEditor(text: $text)
                .frame(height: height)
                .background(Color.clear)
                .cornerRadius(8)
                .padding(4)
        }
    }
}

//Custom SearchBar
struct SearchBar: UIViewRepresentable {
    @Binding var searchQuery: String
    var onSearch: (String) -> Void
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchQuery
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            if let query = searchBar.text {
                parent.onSearch(query)
            }
        }
    }
}

//Custom PinView (Not used)
struct PinView: View {
    var body: some View {
        Image(systemName: "mappin")
            .foregroundColor(.red)
            .font(.title)
    }
}

//Custom ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

