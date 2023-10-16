import SwiftUI
import ARKit
import CoreData

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
    var viewContext: NSManagedObjectContext
    
    init(facility: Facility, viewContext: NSManagedObjectContext) {
        print("ScanningAndAnnotatingFacilityViewModel.init")
        self.facility = facility
        self.viewContext = viewContext
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.facilityCameraTrackingStateChanged(_:)),
                                               name: FacilityScanningCoordinator.facilityCameraTrackingStateChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchPin(_:)),
                                               name: FacilityScanningCoordinator.fetchPinNotification,
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
        if(!self.hasWorldMapLoaded && facilityCameraTrackingState == .normal) {
            self.hasWorldMapLoaded = true
            loadWorldMap()
        }
    }
    
    @objc
    private func fetchPin(_ notification: Notification) {
        guard let pinReadyCallback = notification.userInfo?[FacilityScanningCoordinator.pinReadyCallbackKey] as? PinReadyCallback else { return }
        guard let pinId = notification.userInfo?[FacilityScanningCoordinator.pinIdKey] as? String else { return }
        guard let node = notification.userInfo?[FacilityScanningCoordinator.nodeKey] as? SCNNode else { return }
        
        let fetchRequest: NSFetchRequest<TextPin> = TextPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", pinId as CVarArg)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let foundTextPin = results.first {
                pinReadyCallback.pinReady(pin: foundTextPin, node: node)
            } else {
                print("No TextPin with the given id was found.")
            }
        } catch {
            print("Failed to fetch TextPin with error: \(error)")
        }
    }
    
    
}
