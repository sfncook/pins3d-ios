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
                    infoMessageContent
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
            }// ZStack
            .navigationBarTitle(contextualBarTitle(), displayMode: .inline)
            
            .sheet(isPresented: $viewModel.showCreateAreaFragment) {
                CreateAreaFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreatePinTypeFragment) {
                CreatePinTypeFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreateStepFragment) {
                CreateStepFragment(viewModel: viewModel)
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
        if viewModel.isPlacingStepPin {
            return Button(action: {
                //TODO: Set isPlacingStepPin = false, creatingProcedure=nil, and save pins and stuff
                viewModel.isPlacingStepPin = false
                viewModel.coordinator.showAllAreaPins()
                viewModel.creatingProcedure = nil
            }) {
                HStack {
                    Text("Done")
                }
            }
            .disabled(viewModel.showCreatePinTypeFragment || viewModel.showCreateAreaFragment)
        } else {
            return Button(action: {viewModel.saveWorldMap()}) {
                HStack {
                    Text("Save")
                }
            }
            .disabled(viewModel.showCreatePinTypeFragment || viewModel.showCreateAreaFragment)
        }
    }
    
    func dropPinButton() -> some View {
        if let cursorOverProcedure = viewModel.cursorOverProcedure {
            return AnyView(
                Button(action: {
                    print("Click start procedure")
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
        } else {
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
        }
    }
    
    func contextualBarTitle() -> String {
        if viewModel.isPlacingStepPin {
            return viewModel.creatingProcedure?.name ?? "Creating Nameless Procedure"
        }
        return $viewModel.facility.wrappedValue?.name ?? "Scanning New Area"
    }
    
    var infoMessageContent: Text? {
        if viewModel.isPlacingStepPin {
            return Text("Place Step #\(viewModel.creatingStepNumber)")
        }
        return nil
    }
}
