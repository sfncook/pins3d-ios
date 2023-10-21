import SwiftUI
import ARKit
import CoreData

struct ScanningFacilityView: View {
    @StateObject var viewModel: ScanningFacilityViewModel
    @Binding var showThisView: Bool
    static let darkPurple = UIColor(red: 0.412, green: 0.475, blue: 0.753, alpha: 1.0)
    
    init(facility: Facility?, showScanningFacilityView: Binding<Bool>, viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: ScanningFacilityViewModel(facility: facility, viewContext: viewContext)
        )
        self._showThisView = showScanningFacilityView
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                FacilityScanningARViewContainer2(coordinator: viewModel.coordinator)
                VStack {
                    HStack {
                        savingMessageContent
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        infoMessageContent
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .foregroundColor(.black)
                    }
                    
                    scanningMessageContent
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack {
                        dropPinButton()
                    }.padding(.bottom, 20)
                }
                .padding(.top, 10)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: leadingNavBarButton(),
                    trailing: trailingNavBarButton()
                )
                
                VStack {
                    Spacer()
                    panCameraImage()
                    Spacer()
                    procedureStepOverlay()
                }
            }// ZStack
            .navigationBarTitle(contextualBarTitle(), displayMode: .inline)
            
            .sheet(isPresented: $viewModel.showCreateAreaFragment, onDismiss: {
                if viewModel.facility == nil {
                    self.showThisView = false
                }
            }) {
                CreateAreaFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreatePinTypeFragment) {
                CreatePinTypeFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreateStepFragment) {
                CreateStepFragment(scanningViewModel: viewModel)
            }
        }// NavigationView {
    }// body
    
    func leadingNavBarButton() -> some View {
        if viewModel.isPlacingStepPin {
            return AnyView(EmptyView())
        } else {
            return AnyView(Button(action: {self.showThisView = false}) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
            })
        }
    }
    
    func trailingNavBarButton() -> some View {
        if viewModel.executingStep != nil {
            return AnyView(EmptyView())
        } else if viewModel.isPlacingStepPin {
            return AnyView(Button(action: {
                viewModel.doneCreatingStepsForProcedure()
            }) {
                HStack {
                    Text("Done")
                }
            }
            .disabled(viewModel.showCreatePinTypeFragment || viewModel.showCreateAreaFragment))
        } else if $viewModel.scanningMode.wrappedValue {
            return AnyView(Button(action: {
                viewModel.saveWorldMap()
            }) {
                HStack {
                    Text("Save")
                }
            }
            .disabled(
                viewModel.initializing ||
                viewModel.showCreatePinTypeFragment ||
                viewModel.showCreateAreaFragment ||
                !viewModel.hasEnoughMapPoints
            ))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func dropPinButton() -> some View {
        if viewModel.executingStep != nil ||
            viewModel.scanningMode
        {
            return AnyView(EmptyView())
        } else if viewModel.isPlacingStepPin {
            return AnyView(
                Button(action: {
                    viewModel.dropPin()
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color(uiColor: ScanningFacilityView.darkPurple))
                        
                        Text("Locate Step #\(viewModel.creatingStepNumber)")
                            .font(.system(size: 20)) // Increased font size
                    }
                    .padding() // Padding around the VStack to create some space for the border
                    .background(Color.white) // White background for the VStack
                    .cornerRadius(20) // Rounded corners for the background
                    .overlay( // Overlay used to apply the border around the VStack
                        RoundedRectangle(cornerRadius: 20) // The same corner radius as the background
                            .stroke(Color.blue, lineWidth: 2) // Blue border with a width of 2
                    )
                }
            )
        } else if viewModel.executingProcedure==nil, let cursorOverProcedure = viewModel.cursorOverProcedure {
            return AnyView(
                Button(action: {
                    viewModel.startExecutingProcedure(procedure: cursorOverProcedure)
                }) {
                    HStack {
                        Image(systemName: "play.circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color(uiColor: ScanningFacilityView.darkPurple))
                        
                        Text("Start Procedure")
                            .font(.system(size: 20)) // Increased font size
                    }
                    .padding() // Padding around the VStack to create some space for the border
                    .background(Color.white) // White background for the VStack
                    .cornerRadius(20) // Rounded corners for the background
                    .overlay( // Overlay used to apply the border around the VStack
                        RoundedRectangle(cornerRadius: 20) // The same corner radius as the background
                            .stroke(Color.blue, lineWidth: 2) // Blue border with a width of 2
                    )
                }
            )
        } else if $viewModel.pinDropMode.wrappedValue {
            return AnyView(
                Button(action: {
                    viewModel.dropPin()
                }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 75))
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(Color(uiColor: ScanningFacilityView.darkPurple))
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func contextualBarTitle() -> String {
        if viewModel.isPlacingStepPin {
            return viewModel.creatingProcedure?.name ?? "Creating Nameless Procedure"
        }
        return $viewModel.facility.wrappedValue?.name ?? "Scanning New Area"
    }
    
    var infoMessageContent: Text? {
        if let infoMsg = viewModel.infoMsg {
            return Text(infoMsg)
        }
        return nil
    }
    
    var savingMessageContent: Text? {
        if let savingMsg = viewModel.savingMsg {
            return Text(savingMsg)
        }
        return nil
    }
    
    var scanningMessageContent: Text? {
        if viewModel.scanningMode, let scanningAnimated = viewModel.scanningAnimated {
            return Text(scanningAnimated)
        }
        return nil
    }
    
    func procedureStepOverlay() -> some View {
        if let executingStep = viewModel.executingStep, let executingProcedure = viewModel.executingProcedure {
            return AnyView(
                StepFragment(
                    viewModel: viewModel,
                    executingStep: $viewModel.executingStep,
                    hasNextStep: $viewModel.hasNextStep,
                    hasPrevStep: $viewModel.hasPrevStep
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func panCameraImage() -> some View {
        if viewModel.executingStep != nil, let panCameraDirection = viewModel.panCameraDirection {
            if panCameraDirection=="On Screen" {
                return AnyView(EmptyView())
            } else {
                let systemName = "arrow.\(panCameraDirection)"
                return AnyView(
                    Image(systemName: systemName)
                        .font(.system(size: 75))
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(Color(uiColor: ScanningFacilityView.darkPurple))
                )
            }
        } else {
            return AnyView(EmptyView())
        }
    }
}
