import SwiftUI

struct CreateAreaFragment: View {
    let viewModel: ScanningFacilityViewModel
    @State private var pinText: String = ""
    
    var body: some View {
        VStack {
            Text("What type of pin?")
            
            TextField("Pin text", text: $pinText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.addTextPin(pinTest: pinText)
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }) {
                Text("Text Pin")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button(action: {
                viewModel.addProcedurePin(pinTest: pinText)
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }) {
                Text("Procedure Pin")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(
            minWidth: UIScreen.main.bounds.width,
            maxWidth: UIScreen.main.bounds.width,
            maxHeight: UIScreen.main.bounds.height,
            alignment: .top
        )
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}
