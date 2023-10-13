import SwiftUI
import ARKit

struct ScanningMachineView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: ScanningMachineViewModel
    
    init(_ machine: Machine) {
        viewModel = ScanningMachineViewModel(machine: machine)
    }
    
    var infoMessageContent: Text {
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
                if($viewModel.showSavingMsg.wrappedValue && $viewModel.savingMsg.wrappedValue != nil) {
                    return Text($viewModel.savingMsg.wrappedValue!)
                } else {
                    return Text("Scanning")
                }
            default:
                return Text("Scanning")
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
    
    var body: some View {
        ZStack {
//            NavigationLink(
//                destination: AnnotatingMachineView($viewModel.machine.wrappedValue),
//                isActive: $viewModel.navigateAnnotatingMachineView
//            ) {
//                EmptyView()
//            }.opacity(0)
            
            ARViewContainer()
            
            if viewModel.navigateAnnotatingMachineView {
                Text("What about the fudge?")
                    .background(Color.white)
                    .foregroundColor(.blue)
            }

            VStack {
                infoMessageContent
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        viewModel.resetAppAndScanningStates()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if $viewModel.showSetScanningReadyButton.wrappedValue {
                        Button(action: {
                            print("Clicked Set Scanning Read")
                            viewModel.setScanningReady()
                        }) {
                            Text("SetScanningReady")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.all, 20)
                    } else if $viewModel.showStartDefiningBoxButton.wrappedValue {
                        Button(action: {
                            print("Clicked Definining Box")
                            viewModel.startDefiningBox()
                        }) {
                            Text("Start Defining Box")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.all, 20)
                    } else if $viewModel.showStartScanningButton.wrappedValue {
                        Button(action: {
                            print("Clicked Start Scanning")
                            viewModel.startScanning()
                        }) {
                            Text("Start Scanning")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.all, 20)
                    } else if $viewModel.showScanningButtons.wrappedValue {
                        Button(action: {
                            print("Save pressed")
                            viewModel.saveModel()
                        }) {
                            Text("Save")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.all, 20)
            }
            .padding(.top, 10)
        }
        .navigationBarTitle("Machine Scan", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("ScanningMachineView.OnAppear \($viewModel.navigateAnnotatingMachineView.wrappedValue)")
            viewModel.updateCenter()
        }
    }
}
