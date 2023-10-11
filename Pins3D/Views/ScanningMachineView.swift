import SwiftUI
import ARKit

struct ScanningMachineView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ARViewContainer()

            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("Done pressed")
                    }) {
                        Text("Done")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.all, 20)
            }
        }
        .navigationBarTitle("Machine Scan", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
}
