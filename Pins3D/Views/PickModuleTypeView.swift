import SwiftUI

struct PickModuleTypeView: View {
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: ThirdDetailView()) {
                Text("Facility Scan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            NavigationLink(destination: CreateMachineView()) {
                Text("Machine Scan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            NavigationLink(destination: ThirdDetailView()) {
                Text("Procedure")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            .navigationBarTitle("Module type?", displayMode: .inline)
            
            Spacer()
        }
        .padding(.vertical)
    }
}
