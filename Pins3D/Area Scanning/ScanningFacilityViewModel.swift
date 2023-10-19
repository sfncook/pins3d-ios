import SwiftUI
import ARKit
import CoreData

class ScanningFacilityViewModel: ObservableObject, FetchPinWithId, CursorActions, LoadAnchorsCompleteCallback {
    
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
    @Published var previewingProcedure: Procedure?
    @Published var executingProcedure: Procedure?
    @Published var executingStep: Step?
    @Published var hasNextStep: Bool = false
    @Published var hasPrevStep: Bool = false
    @Published var panCameraDirection: String?
    
    @Published var infoMsg: String?
    var timerInfoMsg: Timer?
    @Published var savingMsg: String?
    var timerSavingMsg: Timer?
    
    init(facility: Facility?, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
        
        if let facility = facility {
            self.preloadAllImages(facility: facility)
        }
        
        // Initialize the coordinator before using 'self' in any closure or method
        coordinator = FacilityScanningCoordinator2(
            fetchPinWithId: self,
            cursorActionsDelegate: self,
            loadAnchorsCompleteCallback: self
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.facility == nil {
                self.showCreateAreaFragment = true
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
    
    func startTimerInfoMsg(infoMsg: String) {
        DispatchQueue.main.async {
            self.clearTimerInfoMsg()
            self.infoMsg = infoMsg
            self.timerInfoMsg = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.infoMsg = nil
            }
        }
    }
    
    func clearTimerInfoMsg() {
        timerInfoMsg?.invalidate()
        timerInfoMsg = nil
    }
    
    func setSavingMsg(savingMsg: String, withTimeout: Bool = false) {
        DispatchQueue.main.async {
            self.clearTimerSavingMsg()
            self.savingMsg = savingMsg
            if withTimeout {
                self.timerSavingMsg = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    self?.savingMsg = nil
                }
            }
        }
    }
    
    func clearTimerSavingMsg() {
        self.savingMsg = nil
        timerSavingMsg?.invalidate()
        timerSavingMsg = nil
    }
    
    func pauseArSession() {
        coordinator.pauseArSession()
    }
    
    func resumeArSession() {
        coordinator.resumeArSession()
    }
    
    func convertToCamelCase(_ input: String) -> String {
        return input.lowercased()
            .replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\.", with: "", options: .regularExpression)

    }
}
