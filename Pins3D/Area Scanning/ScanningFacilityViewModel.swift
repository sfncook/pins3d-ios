import SwiftUI
import ARKit
import CoreData
import Combine

class ScanningFacilityViewModel: 
    ObservableObject,
        FetchPinWithId,
        CursorActions,
        LoadAnchorsCompleteCallback,
        UpdateWorldTrackingStatus {
    
    @Published var initializing: Bool = true
    @Published var showCreateAreaFragment: Bool = false
    @Published var showCreatePinTypeFragment: Bool = false
    @Published var showCreateStepFragment: Bool = false
    @Published var isPlacingStepPin: Bool = false
    @Published var creatingStepNumber: Int = 0
    @Published var creatingProcedure: Procedure?
    
    var facility: Facility? = nil
    let viewContext: NSManagedObjectContext
    var coordinator: FacilityScanningCoordinator2!
    
    @Published var scanningMode: Bool = false
    @Published var hasEnoughMapPoints: Bool = false
    @Published var scanningAnimated: String? = "Scanning."
    private var timer: Timer?
    private var cancellable: AnyCancellable?
    @Published var pinDropMode: Bool = false
    
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
            loadAnchorsCompleteCallback: self,
            updateWorldTrackingStatusDelegate: self
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.facility == nil {
                self.showCreateAreaFragment = true
            } else {
                self.loadWorldMap()
            }
            
        }
    }//init
    
    deinit {
        stopScanningAnimation()
    }
    
    func createNewFacility(facilityName: String) {
        facility = Facility(context: viewContext)
        facility!.id = UUID()
        facility!.name = facilityName
        DispatchQueue.main.async {
            self.scanningMode = true
            self.startScanningAnimation()
            self.initializing = false
        }
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
    
    func startScanningAnimation() {
        timer?.invalidate() // Invalidate any existing timer
        
        // Schedule a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            switch self.scanningAnimated {
            case "Scanning.":
                self.scanningAnimated = "Scanning.."
            case "Scanning..":
                self.scanningAnimated = "Scanning..."
            default:
                self.scanningAnimated = "Scanning."
            }
        }
        
        // Ensure the timer works in common modes like when user interacts with UI
        RunLoop.current.add(timer!, forMode: .common)
        
        // Handle deallocation
        cancellable = AnyCancellable {
            self.timer?.invalidate()
        }
    }
    
    func stopScanningAnimation() {
        timer?.invalidate()
        timer = nil
        cancellable?.cancel()
        cancellable = nil
    }
    
    func setExtending() {
        self.hasEnoughMapPoints = true
    }
    
    func setMapped() {
        self.hasEnoughMapPoints = true
    }
}
