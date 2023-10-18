import SwiftUI
import ARKit
import CoreData

extension ScanningFacilityViewModel {
    func onCursorOverProcedurePin(procedureId: UUID) {
        cursorOverProcedure = fetchProcedure(procedureId: procedureId)
    }
    
    func onCursorOutProcedurePin() {
        cursorOverProcedure = nil
    }
}
