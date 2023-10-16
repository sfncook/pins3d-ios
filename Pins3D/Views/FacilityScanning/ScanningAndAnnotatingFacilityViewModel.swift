import SwiftUI
import ARKit

class ScanningAndAnnotatingFacilityViewModel: ObservableObject {
    
    var facility: Facility
    
    init(_ facility: Facility) {
        self.facility = facility
    }
    
    func onDropPin() {
//        guard let hitTestResult = ARSCNView.sceneView!
//            .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
//            .first
//            else { return }
        
//        DispatchQueue.main.async {
//            let scnView = ARSCNView.sceneView!
//            let screenPos = CGPoint(x: scnView.bounds.midX, y: scnView.bounds.midY)
//            let hitResults = scnView.hitTest(screenPos, types: [.featurePoint])
//            if !hitResults.isEmpty {
//                let hit = hitResults[0]
//                self.hitNodePointedAt = hit.node
//                self.sphereNode.removeFromParentNode()
//                self.hitNodePointedAt?.addChildNode(self.sphereNode)
//            }
//        }
    }
    
}
