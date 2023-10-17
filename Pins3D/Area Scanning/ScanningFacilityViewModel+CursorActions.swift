import SwiftUI
import ARKit
import CoreData

extension ScanningFacilityViewModel {
    func onCursorOverProcedurePin(procedure: Procedure) {
        cursorOverProcedure = procedure
    }
    
    func onCursorOutProcedurePin() {
        cursorOverProcedure = nil
    }
}
