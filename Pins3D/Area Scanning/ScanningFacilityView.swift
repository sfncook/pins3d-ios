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
                        Button(action: {
                            viewModel.dropPin()
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 75))
                                .background(Color.white)
                                .clipShape(Circle())
                                .foregroundColor(Color(uiColor: ScanningFacilityView.darkPurple))
                        }
                    }.padding(.bottom, 20)
                }
                .padding(.top, 10)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: Button(action: {self.showThisView = false}) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                    },
                    trailing: Button(action: {viewModel.saveWorldMap()}) {
                        HStack {
                            Text("Save")
                        }
                    }
                        .disabled(viewModel.showCreatePinTypeFragment || viewModel.showCreateAreaFragment)
                )
            }// ZStack
            .navigationBarTitle(contextualBarTitle(), displayMode: .inline)
            
            .sheet(isPresented: $viewModel.showCreateAreaFragment) {
                CreateAreaFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreatePinTypeFragment) {
                CreatePinTypeFragment(viewModel: viewModel)
            }
        }// NavigationView {
    }// body
    
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
