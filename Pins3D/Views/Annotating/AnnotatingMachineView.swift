import SwiftUI
import ARKit

struct AnnotatingMachineView: View {
    @ObservedObject var viewModel: AnnotatingMachineViewViewModel
    
    init(_ machine: Machine) {
        viewModel = AnnotatingMachineViewViewModel(machine: machine)
    }
    
    var body: some View {
        ZStack {
//            ARViewContainer()

            VStack {
                Spacer()
                
                Button(action: {
//                    viewModel.resetAppAndScanningStates()
//                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Drop Pin")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 10)
        }
        .navigationBarTitle($viewModel.machine.wrappedValue.name ?? "Add Pins for Machine", displayMode: .inline)
    }
}
