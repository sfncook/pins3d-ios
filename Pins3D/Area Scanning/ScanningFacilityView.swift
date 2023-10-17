import SwiftUI
import ARKit
import CoreData

struct ScanningFacilityView: View {
    @StateObject var viewModel: ScanningFacilityViewModel
    @Binding var showThisView: Bool
    
    init(facility: Facility?, showScanningFacilityView: Binding<Bool>, viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: ScanningFacilityViewModel(facility: facility, viewContext: viewContext)
        )
        self._showThisView = showScanningFacilityView
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                FacilityScanningARViewContainer()
                VStack {
                    infoMessageContent
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                $viewModel.showCreateAreaFragment.wrappedValue.toggle()
                            }
                        }) {
                            Text("Drop Pin")
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 10)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading:
                                        Button(action: {
                    self.showThisView = false
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
                )
            }// ZStack
            .navigationBarTitle($viewModel.facility.wrappedValue?.name ?? "Scanning New Area", displayMode: .inline)
            
            .sheet(isPresented: $viewModel.showCreateAreaFragment, onDismiss: {
                print("Dimiss showModal:\(viewModel.showCreateAreaFragment)")
            }) {
                CreateAreaFragment(viewModel: viewModel)
            }
        }// NavigationView {
    }// body
    
    var infoMessageContent: Text? {
        return nil
    }
}
