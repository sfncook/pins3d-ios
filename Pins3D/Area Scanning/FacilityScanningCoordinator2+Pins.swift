import ARKit

extension FacilityScanningCoordinator2 {
    
    // This is called anytime new anchors are added to the scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorName = anchor.name
            else { return }
        
        if !self.firstAnchorLoaded {
            self.loadAnchorsCompleteCallback.loadAnchorsComplete()
            self.firstAnchorLoaded = true
        }
        print("FacilityScanningCoordinator anchor/pin added:\(anchorName)")
        if anchorName.hasPrefix("textpin_") {
            let pinId = String(anchorName.dropFirst("textpin_".count))
            if let textPin = fetchPinWithId.fetchTextPin(pinId: pinId) {
                let textPinNode = TextPinNode(textPin)
                node.addChildNode(textPinNode)
//                pinNodes.append(textPinNode)
            } else {
                print("Could not find pin with id: \(pinId)")
            }
        } else if anchorName.hasPrefix("procedurePin_") {
            let pinId = String(anchorName.dropFirst("procedurePin_".count))
            if let procedurePin = fetchPinWithId.fetchProcedurePin(pinId: pinId) {
                let procedurePinNode = ProcedurePinNode(procedurePin)
                node.addChildNode(procedurePinNode)
                procedurePinNodes.append(procedurePinNode)
            } else {
                print("Could not find pin with id: \(pinId)")
            }
        } else if anchorName.hasPrefix("stepPin_") {
            let pinId = String(anchorName.dropFirst("stepPin_".count))
            if let stepPin = fetchPinWithId.fetchStepPin(pinId: pinId) {
                let stepPinNode = StepPinNode(stepPin)
                node.addChildNode(stepPinNode)
//                pinNodes.append(stepPinNode)
            } else {
                print("Could not find pin with id: \(pinId)")
            }
        } else {
            print("Unknown pin type w/ anchorname:\(anchorName)")
        }
        updateShowHidePinNodes()
    }
    
    func getPinCursorLocation() -> simd_float4x4? {
        return pinCurorWorldTransform
    }
    
    func addPin(pin: Pin, transform: simd_float4x4) {
        if let stepPin = pin as? StepPin {
            print("Adding StepPin to scene")
            let anchor = ARAnchor(name: "stepPin_\(stepPin.id!)", transform: transform)
            ARSCNView.sceneView!.session.add(anchor: anchor)
        } else if let procedurePin = pin as? ProcedurePin {
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
    
    func showAllAreaPins() {
        nodeTypesToShow = [ProcedurePinNode.typeName, TextPinNode.typeName]
        highlightStepPin = nil
        updateShowHidePinNodes()
    }
    
    func showOnlyStepPinsForProcedure(procedure: Procedure) {
        nodeTypesToShow = [StepPinNode.typeName]
        stepPinsToShow = fetchPinWithId.fetchStepPinsForProcedure(procedure: procedure)
        highlightStepPin = nil
        updateShowHidePinNodes()
    }
    
    func showAllStepPinsForProcedure(highlightStep: Step, procedure: Procedure) {
        guard let highlightStepPin = highlightStep.pin else {
            return
        }
        nodeTypesToShow = [StepPinNode.typeName]
        stepPinsToShow = fetchPinWithId.fetchStepPinsForProcedure(procedure: procedure)
        self.highlightStepPin = highlightStepPin
        updateShowHidePinNodes()
    }
    
    func updateShowHidePinNodes() {
        ARSCNView.sceneView!.scene.rootNode.enumerateChildNodes { (node, stop) in
            if let name = node.name {
                if nodeTypesToShow.contains(StepPinNode.typeName) {
                    if let stepPinNode = node as? StepPinNode {
                        node.isHidden = !stepPinsToShow.contains(stepPinNode.stepPin)
                        if !node.isHidden {
                            if self.highlightStepPin == stepPinNode.stepPin {
                                stepPinNode.addHighlight()
                            } else {
                                stepPinNode.removeHighlight()
                            }
                        }
                    } else {
                        // Not a stepPin so hide it
                        node.isHidden = true
                    }
                } else {
                    node.isHidden = !nodeTypesToShow.contains(name)
                }
            }
        }
    }
    
    func findHighlightedPin(renderer: SCNSceneRenderer) {
        guard let highlightStepPin = highlightStepPin else {return}
        
        // Find StepNode for hightlightStepPin
        ARSCNView.sceneView!.scene.rootNode.enumerateChildNodes { (node, stop) in
            if let specialNode = node as? StepPinNode {
                if highlightStepPin == specialNode.stepPin {
                    // Project the 3D position of the specialNode into the camera's 2D space
                    let projectedPoint = renderer.projectPoint(specialNode.worldPosition)

                    if let view = renderer as? SCNView {
                        DispatchQueue.main.async {
                            let size = view.bounds.size
                            let normalizedPoint = CGPoint(x: CGFloat(projectedPoint.x) / size.width,
                                                          y: CGFloat(projectedPoint.y) / size.height)
                            
                            // Check if the node is visible on the screen
                            if (0...1).contains(normalizedPoint.x) && (0...1).contains(normalizedPoint.y) {
                                //                            hideDirectionalArrow()
                                self.fetchPinWithId.panCameraToSeeHighlightedPoint("On Screen")
                            } else {
                                // Determine and show the directional arrow
                                if normalizedPoint.x < 0 {
                                    self.fetchPinWithId.panCameraToSeeHighlightedPoint("left")
                                } else if normalizedPoint.x > 1 {
                                    self.fetchPinWithId.panCameraToSeeHighlightedPoint("right")
                                } else if normalizedPoint.y < 0 {
                                    self.fetchPinWithId.panCameraToSeeHighlightedPoint("up")
                                } else if normalizedPoint.y > 1 {
                                    self.fetchPinWithId.panCameraToSeeHighlightedPoint("down")
                                }
                            }
                        }
                    }
                }//
            }
        }
    }
}

protocol FetchPinWithId {
    func fetchTextPin(pinId: String) -> TextPin?
    func fetchProcedurePin(pinId: String) -> ProcedurePin?
    func fetchStepPin(pinId: String) -> StepPin?
    func fetchStepPinsForProcedure(procedure: Procedure) -> [StepPin]
    func panCameraToSeeHighlightedPoint(_ direction: String)
}
