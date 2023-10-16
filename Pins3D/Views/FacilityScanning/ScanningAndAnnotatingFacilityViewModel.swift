import SwiftUI
import ARKit

class ScanningAndAnnotatingFacilityViewModel: ObservableObject {
    
    var facility: Facility
    
    init(_ facility: Facility) {
        self.facility = facility
    }
    
}
