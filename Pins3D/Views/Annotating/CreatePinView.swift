import SwiftUI

struct CreatePinView: View {
    
    @State private var pinTextLocal: String = ""
    @Binding var pinText: String
    @Binding var showCreatePinView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter pin text", text: $pinTextLocal)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                pinText = pinTextLocal
                showCreatePinView = false
            }) {
                Text("Drop a Text Pin")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            .navigationBarTitle("Pin Info?", displayMode: .inline)
            
            Spacer()
        }
        .padding(.vertical)
    }
}
