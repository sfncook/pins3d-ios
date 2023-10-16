import SwiftUI

struct CreateAreaFragment: View {
    @State private var areaName: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter area name", text: $areaName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
//                saveNewPin()
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
