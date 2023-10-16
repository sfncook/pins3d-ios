import SwiftUI
import ARKit

class ScanningAndAnnotatingFacilityViewModel: ObservableObject, AddPinCallback {
    
    static let addPinToFacilityNotification = Notification.Name("addPinToFacilityNotification")
    static let pinFacilityKey = "pinFacilityKey"
    @Published var showCreatePinView: Bool = false
    @Published var annotationPointX: Float?
    @Published var annotationPointY: Float?
    @Published var annotationPointZ: Float?
    
    var facility: Facility
    
    init(_ facility: Facility) {
        self.facility = facility
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
    
}
