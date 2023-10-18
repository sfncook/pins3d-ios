import SwiftUI
import ARKit
import CoreData

class ScanningFacilityViewModel: ObservableObject, FetchPinWithId, CursorActions {
    
    @Published var showCreateAreaFragment: Bool = false
    @Published var showCreatePinTypeFragment: Bool = false
    @Published var showCreateStepFragment: Bool = false
    @Published var isPlacingStepPin: Bool = false
    @Published var creatingStepNumber: Int = 0
    @Published var creatingProcedure: Procedure?
    
    var facility: Facility? = nil
    let viewContext: NSManagedObjectContext
    var coordinator: FacilityScanningCoordinator2!
    
    var pinCursorLocationWhenDropped: simd_float4x4?
    @Published var cursorOverProcedure: Procedure?
    @Published var executingProcedure: Procedure?
    @Published var executingStep: Step?
    @Published var hasNextStep: Bool = false
    @Published var hasPrevStep: Bool = false
    
    init(facility: Facility?, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
        
        // Initialize the coordinator before using 'self' in any closure or method
        coordinator = FacilityScanningCoordinator2(fetchPinWithId: self, cursorActionsDelegate: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.facility == nil {
                self.showCreateAreaFragment = self.facility == nil
            } else {
                self.loadWorldMap()
            }
            
        }
    }
    
    func createNewFacility(facilityName: String) {
        facility = Facility(context: viewContext)
        facility!.id = UUID()
        facility!.name = facilityName
        saveFacility()
    }
}
