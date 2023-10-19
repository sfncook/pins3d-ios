import SwiftUI

struct CreateStepFragment: View {
    let scanningViewModel: ScanningFacilityViewModel
    @State private var stepSummary: String = ""
    @State private var stepDetails: String = ""
    
    @State private var showImageActionPicker = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var image: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                Text("Add Step")
                    .font(.title)
                    .bold()
                Spacer().frame(height: 16)
                
                Text("Procedure Name")
                    .font(.caption)
                    .padding(.bottom, 2)
                Text(scanningViewModel.creatingProcedure?.name ?? "NOT SET")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer().frame(height: 16)
                
                Text("Step Number")
                    .font(.caption)
                Text("\(scanningViewModel.creatingStepNumber)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Summary")
                    .font(.caption)
                    .padding(.bottom, 2)
                TextField("Step Summary", text: $stepSummary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .border(Color.gray, width: 1)
                
                Text("Details (optional)")
                    .font(.caption)
                    .padding(.bottom, 2)
                TextEditor(text: $stepDetails)
                    .frame(height: 60, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button(action: {
                    self.showImageActionPicker.toggle()
                }) {
                    Text("Add Photo (optional)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .actionSheet(isPresented: $showImageActionPicker) {
                    ActionSheet(title: Text("Select a photo source"), buttons: [
                        .default(Text("Photo Library")) {
                            self.showCamera = false
                            self.showImagePicker = true
                        },
                        .default(Text("Camera")) {
                            self.showCamera = true
                            self.showImagePicker = true
                        },
                        .cancel()
                    ])
                }
                
                image.map {
                    Image(uiImage: $0)
                        .resizable()
                        .frame(width: 300, height: 300)
                }
                
                Button(action: {
                    scanningViewModel.addStepPin(
                        stepSummary: stepSummary,
                        stepDetails: stepDetails
                    )
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }) {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }//ScrollView
        }//Vstack
        .padding()
        .background(Color.white)
        .cornerRadius(5)
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$image, sourceType: self.showCamera ? .camera : .photoLibrary)
        }
    }//body
}
