import SwiftUI
import ARKit
import CoreData

class ScanningFacilityViewModel: ObservableObject {
    
    var facility: Facility? = nil
    let viewContext: NSManagedObjectContext
    
    init(facility: Facility?, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
    }
}
