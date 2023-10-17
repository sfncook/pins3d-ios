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
                    trailing: Button(action: {viewModel.saveFacility()}) {
                        HStack {
                            Text("Save")
                        }
                    }
                        .disabled(viewModel.showCreatePinTypeFragment || viewModel.showCreateAreaFragment)
                )
            }// ZStack
            .navigationBarTitle($viewModel.facility.wrappedValue?.name ?? "Scanning New Area", displayMode: .inline)
            
            .sheet(isPresented: $viewModel.showCreateAreaFragment) {
                CreateAreaFragment(viewModel: viewModel)
            }
            
            .sheet(isPresented: $viewModel.showCreatePinTypeFragment) {
                CreatePinTypeFragment(viewModel: viewModel)
            }
        }// NavigationView {
    }// body
    
    var infoMessageContent: Text? {
        return nil
    }
}
