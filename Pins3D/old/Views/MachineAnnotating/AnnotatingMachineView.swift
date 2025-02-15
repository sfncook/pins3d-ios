import SwiftUI
import ARKit

struct AnnotatingMachineView: View {
    @StateObject var viewModel: AnnotatingMachineViewModel
    @Binding var showAnnotatingMachineView: Bool
    @State var createdPin: TextPin? = nil
    
    init(_ machine: Machine, showAnnotatingMachineView: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: AnnotatingMachineViewModel(machine: machine))
        self._showAnnotatingMachineView = showAnnotatingMachineView
    }
    
    var body: some View {
        ZStack {
            ARViewContainer()

            VStack {
                infoMessageContent
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.black)
                
                Spacer()
                
                /*if $viewModel.showStartLoadButtons.wrappedValue {
                    Button(action: {
                        viewModel.loadModel()
                    }) {
                        Text("Load Model")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                } else*/ if $viewModel.hasObjectBeenDetected.wrappedValue {
                    Button(action: {
                        viewModel.onDropPin()
                    }) {
                        Text("Drop Pin")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    .sheet(isPresented: $viewModel.showCreatePinView, onDismiss: {
                        print("CreatePinView onDismiss pin:\(self.createdPin?.text ?? "NOT_SET")")
                        if self.createdPin != nil {
                            viewModel.addPin(pin: self.createdPin!)
                        }
                        self.createdPin = nil
                    }) {
                        CreatePinView(
                            viewModel: viewModel,
                            x: viewModel.annotationPointX!,
                            y: viewModel.annotationPointY!,
                            z: viewModel.annotationPointZ!,
                            showCreatePinView: $viewModel.showCreatePinView,
                            createdPin: self.$createdPin
                        )
                    }
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
    
    var infoMessageContent: Text? {
        switch $viewModel.cameraTrackingState.wrappedValue {
        case nil:
            return Text("Initializing")
        case .notAvailable:
            return Text("AR not available")
        case .normal:
            switch $viewModel.appState.wrappedValue {
            case .notReady:
                return Text("Not Ready")
            case .startARSession:
                return Text("Ready")
            case .scanning:
                return Text("Scanning")
            case .testing:
                if($viewModel.showLoadingMsg.wrappedValue && $viewModel.loadingMsg.wrappedValue != nil) {
                    return Text($viewModel.loadingMsg.wrappedValue!)
                } else if($viewModel.hasObjectBeenDetected.wrappedValue) {
                    return nil
                } else {
                    return Text("Center camera on the machine")
                }
            default:
                return nil
            }
            
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return Text("ARKit tracking LIMITED: Excessive motion")
            case .insufficientFeatures:
                return Text("ARKit tracking LIMITED: Low detail")
            case .initializing:
                return Text("ARKit is initializing")
            case .relocalizing:
                return Text("ARKit is relocalizing")
            @unknown default:
                return Text("ARKit tracking LIMITED")
            }
        }
    }
}
