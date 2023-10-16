import SwiftUI
import ARKit

class ScanningAndAnnotatingFacilityViewModel: ObservableObject, AddPinCallback, WorldMapReadyCallback {
    
    static let getWorldMapNotification = Notification.Name("getWorldMapNotification")
    static let worldMapReadyCallback = "worldMapReadyCallback"
    static let addPinToFacilityNotification = Notification.Name("addPinToFacilityNotification")
    static let pinFacilityKey = "pinFacilityKey"
    static let loadWorldMapNotification = Notification.Name("loadWorldMapNotification")
    static let worldMapKey = "worldMapKey"
    @Published var showCreatePinView: Bool = false
    @Published var annotationPointX: Float?
    @Published var annotationPointY: Float?
    @Published var annotationPointZ: Float?
    @Published var hasWorldMapLoaded: Bool = false
    
    var facility: Facility
    
    init(_ facility: Facility) {
        self.facility = facility
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.facilityCameraTrackingStateChanged(_:)),
                                               name: FacilityScanningCoordinator.facilityCameraTrackingStateChangedNotification,
                                               object: nil)
    }
    
    func onDropPin() {
        DispatchQueue.main.async {
            let scnView = ARSCNView.sceneView!
            let screenPos = CGPoint(x: scnView.bounds.midX, y: scnView.bounds.midY)
            let hitResults = scnView.hitTest(screenPos, types: [.featurePoint])
            if !hitResults.isEmpty {
                let hit = hitResults[0]
                self.annotationPointX = hit.worldTransform.position.x
                self.annotationPointY = hit.worldTransform.position.y
                self.annotationPointZ = hit.worldTransform.position.z
                self.showCreatePinView = true
            }
        }
    }
    
    func addPin(pin: Pin) {
        NotificationCenter.default.post(name: ScanningAndAnnotatingFacilityViewModel.addPinToFacilityNotification,
                                        object: self,
                                        userInfo: [ScanningAndAnnotatingFacilityViewModel.pinFacilityKey: pin])
    }
    
    func addPinYoMama(pin: TextPin) {
        self.facility.addToPins(pin)
    }
    
    @objc
    private func facilityCameraTrackingStateChanged(_ notification: Notification) {
        guard let facilityCameraTrackingState = notification.userInfo?[FacilityScanningCoordinator.facilityCameraTrackingStateKey] as? ARCamera.TrackingState else { return }
        print("facilityCameraTrackingStateChanged state:\(facilityCameraTrackingState)")
        let initVal = self.hasWorldMapLoaded
        self.hasWorldMapLoaded = facilityCameraTrackingState == .normal
        if(!initVal && self.hasWorldMapLoaded) {
//            loadWorldMap()
        }
    }
    
    
}
