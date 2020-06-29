//
//  ContentView.swift
//  Copyright © 2020 Pyxeda. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State var animalName = "Who is it?"
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage(systemName: "ant.fill")
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                        Text("Animal Friends")
                        Image(uiImage: inputImage!).resizable()
                            .aspectRatio(contentMode: .fit)
                        Text(animalName)
                        Button("Click me now"){
                            self.buttonPressed()
                        }.foregroundColor(.white)
                            .background(Color.green)
                        .cornerRadius(10)
            }
            .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func processImage() {
        self.showingImagePicker = false
        self.animalName="Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        let uploadURL = "https://3h6ys7t373.execute-api.us-east-1.amazonaws.com/Predict/03378121-5f5b-4e24-8b5b-7a029003f2a4"
        
        AF.upload(imageB64, to: uploadURL).responseJSON { response in
            
            debugPrint(response)
            switch response.result {
               case .success(let responseJsonStr):
                   print("\n\n Success value and JSON: \(responseJsonStr)")
                   let myJson = JSON(responseJsonStr)
                   let predictedValue = myJson["predicted_label"].string
                   print("Saw predicted value \(String(describing: predictedValue))")
                   let predictionMessage = "Animal Name: " + predictedValue!
                   self.animalName=predictionMessage
               case .failure(let error):
                   print("\n\n Request failed with error: \(error)")
               }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
 
