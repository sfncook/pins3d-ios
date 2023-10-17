import ARKit

extension FacilityScanningCoordinator2 {
    
    // This is called anytime new anchors are added to the scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorName = anchor.name
            else { return }
        
        print("FacilityScanningCoordinator anchor/pin added:\(anchorName)")
        if anchorName.hasPrefix("textpin_") {
            let pinId = String(anchorName.dropFirst("textpin_".count))
            if let textPin = fetchPinWithId.fetchTextPin(pinId: pinId) {
                let textPinNode = TextPinNode(textPin)
                node.addChildNode(textPinNode)
            } else {
                print("Could not find pin with id: \(pinId)")
            }
        } else if anchorName.hasPrefix("procedurePin_") {
            let pinId = String(anchorName.dropFirst("procedurePin_".count))
            if let procedurePin = fetchPinWithId.fetchProcedurePin(pinId: pinId) {
                let procedurePinNode = ProcedurePinNode(procedurePin)
                node.addChildNode(procedurePinNode)
            } else {
                print("Could not find pin with id: \(pinId)")
            }
        } else {
            print("The string does not start with the prefix 'textpin_'.")
        }
    }
    
    func getPinCursorLocation() -> simd_float4x4? {
        return pinCurorWorldTransform
    }
    
    func addPin(pin: Pin, transform: simd_float4x4) {
        if let procedurePin = pin as? ProcedurePin {
            print("Adding ProcedurePin to scene")
            let anchor = ARAnchor(name: "procedurePin_\(procedurePin.id!)", transform: transform)
            ARSCNView.sceneView!.session.add(anchor: anchor)
        } else if let textPin = pin as? TextPin {
            print("Adding TextPin to scene")
            let anchor = ARAnchor(name: "textpin_\(textPin.id!)", transform: transform)
            ARSCNView.sceneView!.session.add(anchor: anchor)
        } else {
            print("This pin is not a TextPin nor ProcedurePin")
        }

    }
}


protocol FetchPinWithId {
    func fetchTextPin(pinId: String) -> TextPin?
    func fetchProcedurePin(pinId: String) -> ProcedurePin?
}
