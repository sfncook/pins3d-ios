import SwiftUI
import ARKit
import CoreData

class ScanningFacilityViewModel: ObservableObject {
    
    @Published var showCreateAreaFragment: Bool = false
    
    var facility: Facility? = nil
    let viewContext: NSManagedObjectContext
    
    init(facility: Facility?, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showCreateAreaFragment = self.facility == nil
        }
    }
}
