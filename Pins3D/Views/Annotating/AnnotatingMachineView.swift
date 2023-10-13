import SwiftUI
import ARKit

struct AnnotatingMachineView: View {
    @ObservedObject var viewModel: AnnotatingMachineViewViewModel
    @Binding var showAnnotatingMachineView: Bool
    
    init(_ machine: Machine, showAnnotatingMachineView: Binding<Bool>) {
        viewModel = AnnotatingMachineViewViewModel(machine: machine)
        self._showAnnotatingMachineView = showAnnotatingMachineView
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
            .navigationBarBackButtonHidden(true) 
            .navigationBarItems(leading:
                Button(action: {
                    self.showAnnotatingMachineView = false
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
            )
        }
        .navigationBarTitle($viewModel.machine.wrappedValue.name ?? "Add Pins for Machine", displayMode: .inline)
    }
}
