/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A visualization the 3D point cloud data in a detected object.
*/

import Foundation
import ARKit

class DetectedPointCloud: SCNNode, PointCloud {
    
    private let referenceObjectPointCloud: ARPointCloud
    private let center: SIMD3<Float>
    private let extent: SIMD3<Float>
    var sidesNode = SCNNode()
    
    private let MANY_CUBES = 15.0
    private let INCHES_15: Float = 0.381
    private let INCHES_5: Float = 0.127
    private let INCHES_3: Float = 0.0762
    private var manyAnnotations = 0
//    var viewCtl: ViewController?
    
    private let innerCubesColor: UIColor = UIColor.clear
    
    private var sphereNode = SCNNode(geometry: SCNSphere(radius: 0.005))
    
    init(referenceObjectPointCloud: ARPointCloud, center: SIMD3<Float>, extent: SIMD3<Float>, sidesNodeObject: SCNNode?) {
        self.referenceObjectPointCloud = referenceObjectPointCloud
        self.center = center
        self.extent = extent
        super.init()
        
        self.sidesNode = sidesNodeObject ?? SCNNode()
        
        let textNodes = self.sidesNode.childNodes { (node, stop) -> Bool in
            return node.name == "TextNode"
        }
        manyAnnotations = textNodes.count
        
        // Set inner cube material if differs from when it was saved
        let newMaterial = SCNMaterial()
        newMaterial.diffuse.contents = innerCubesColor
        for node in self.sidesNode.childNodes {
            if(node.name == "CubeFill") {
                node.geometry?.materials = [newMaterial]
            }
        }
        
        self.addChildNode(self.sidesNode)
        
        // Semitransparently visualize the reference object's points.
        //        let referenceObjectPoints = SCNNode()
        //        referenceObjectPoints.geometry = createVisualization(for: referenceObjectPointCloud.points, color: .appYellow, size: 12, type: .point)
        //        addChildNode(referenceObjectPoints)
        let minPt: SIMD3<Float> = simdPosition + center - extent / 2
        let maxPt: SIMD3<Float> = simdPosition + center + extent / 2
        
        let deltaX = maxPt.x - minPt.x
        let deltaY = maxPt.y - minPt.y
        let deltaZ = maxPt.z - minPt.z
        let diagDiameterM = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
        print("diagonal diameter meters: \(diagDiameterM)")
        var childCubeSize = SIMD3<Float>(x: INCHES_3, y: INCHES_3, z: INCHES_3)
        if(diagDiameterM < INCHES_15) {
            let volumeSize = maxPt - minPt
            childCubeSize = volumeSize / 4.0
        }
        let manyPerSide = diagDiameterM / childCubeSize
        

        func isPointInsideCube(point: simd_float3, min: simd_float3, max: simd_float3) -> Bool {
            return point.x >= min.x && point.x <= max.x &&
                   point.y >= min.y && point.y <= max.y &&
                   point.z >= min.z && point.z <= max.z
        }

        for x in 0..<Int(floor(manyPerSide.x)) {
            for y in 0..<Int(floor(manyPerSide.y)) {
                for z in 0..<Int(floor(manyPerSide.z)) {
                    let childCubeMin = SIMD3<Float>(
                        Float(x) * childCubeSize.x + minPt.x,
                        Float(y) * childCubeSize.y + minPt.y,
                        Float(z) * childCubeSize.z + minPt.z
                    )
                    
                    let childCubeMax = childCubeMin + childCubeSize
                    
                    var hasPointInside = false
                    
                    for point in referenceObjectPointCloud.points {
                        if isPointInsideCube(point: point, min: childCubeMin, max: childCubeMax) {
                            hasPointInside = true
                            break
                        }
                    }
                    
                    if hasPointInside {
                        let childCubeCenter = SIMD3<Float>(
                            childCubeMin.x + childCubeSize.x / 2,
                            childCubeMin.y + childCubeSize.y / 2,
                            childCubeMin.z + childCubeSize.z / 2
                        )
                        
                        let childCube = SCNBox(width: CGFloat(childCubeSize.x), height: CGFloat(childCubeSize.y), length: CGFloat(childCubeSize.z), chamferRadius: 0)
                        let childCubeNode = SCNNode(geometry: childCube)
                        childCubeNode.position = SCNVector3(childCubeCenter.x, childCubeCenter.y, childCubeCenter.z)
                        
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.clear
                        material.lightingModel = .constant
                        material.isDoubleSided = true
                        childCube.materials = [material]
                        
                        childCubeNode.name = "CubeFill"
                        
                        self.sidesNode.addChildNode(childCubeNode)
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.getAnnotationPointCallback(_:)),
                                               name: AnnotatingMachineViewModel.getAnnotationPointNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.addPin(_:)),
                                               name: AnnotatingMachineViewModel.addPinNotification,
                                               object: nil)
    }// init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isPointInsideCube(point: simd_float3, min: simd_float3, max: simd_float3) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }
    
    func updateVisualization(for currentPointCloud: ARPointCloud) {
        guard !self.isHidden else { return }
        
        let min: SIMD3<Float> = simdPosition + center - extent / 2
        let max: SIMD3<Float> = simdPosition + center + extent / 2
        var inlierPoints: [SIMD3<Float>] = []
        
        for point in currentPointCloud.points {
            let localPoint = self.simdConvertPosition(point, from: nil)
            if (min.x..<max.x).contains(localPoint.x) &&
                (min.y..<max.y).contains(localPoint.y) &&
                (min.z..<max.z).contains(localPoint.z) {
                inlierPoints.append(localPoint)
            }
        }
        
        let currentPointCloudInliers = inlierPoints
//        self.geometry = createVisualization(for: currentPointCloudInliers, color: .appGreen, size: 12, type: .point)
        
        
        // Draw user pointer on cube that is pointed at
        DispatchQueue.main.async {
            let scnView = ARSCNView.sceneView!
            let screenPos = CGPoint(x: scnView.bounds.midX, y: scnView.bounds.midY)
            let hitResults = scnView.hitTest(screenPos, options: [
                .rootNode: self.sidesNode,
                .ignoreHiddenNodes: true,
                .backFaceCulling: true,
                .searchMode: SCNHitTestSearchMode.all.rawValue
            ])
            if !hitResults.isEmpty {
                let hit = hitResults[0]
                self.hitNodePointedAt = hit.node
                self.sphereNode.removeFromParentNode()
                self.hitNodePointedAt?.addChildNode(self.sphereNode)
            }
        }
    }
    
    private var hitNodePointedAt: SCNNode?
    
    @objc
    private func getAnnotationPointCallback(_ notification: Notification) {
        guard let getAnnotationPointCallback = notification.userInfo?[AnnotatingMachineViewModel.getAnnotationPointCallbackKey] as? GetAnnotationPointCallback else { return }
        getAnnotationPointCallback.setAnnotationPoint(
            x: self.hitNodePointedAt?.position.x,
            y: self.hitNodePointedAt?.position.y,
            z: self.hitNodePointedAt?.position.z
        )
    }
    @objc
    private func addPin(_ notification: Notification) {
        guard let pin = notification.userInfo?[AnnotatingMachineViewModel.pinKey] as? Pin else { return }
        let targetPosition = SCNVector3(x: pin.x, y: pin.y, z: pin.z)
        let delta: Float = 0.01 // for example
        if let node = self.sidesNode.findChildNode(near: targetPosition, within: delta) {
            self.manyAnnotations += 1
            if let textPin = pin as? TextPin {
                let textPinNode = TextPinNode(textPin)
                node.addChildNode(textPinNode)
//                addAnnotation(node: node, stepNumberText: "\(self.manyAnnotations)", annotationText: textPin.text!)
            } else {
                print("This pin is not a TextPin")
            }
        }

    }
    
    func findNode(named name: String, in node: SCNNode) -> SCNNode? {
        if node.name == name {
            return node
        }
        for childNode in node.childNodes {
            if let result = findNode(named: name, in: childNode) {
                return result
            }
        }
        return nil
    }
    
    func updateCubes(sceneView: ARSCNView, screenPos: CGPoint) {
        let hitResults = sceneView.hitTest(screenPos, options: [
            .rootNode: sidesNode,
            .ignoreHiddenNodes: true,
            .backFaceCulling: true,
            .searchMode: SCNHitTestSearchMode.all.rawValue
        ])

        
        if !hitResults.isEmpty {
            // DEBUGGING: Highlight all hit cubes
//            let newMaterial = SCNMaterial()
//            newMaterial.diffuse.contents = UIColor.red
//            for hitResult in hitResults {
//                let node = hitResult.node
//                print("node name:\(node.name ?? "NOT SET")")
//                for childNode in node.childNodes {
//                    print("childNode name:\(node.name ?? "NOT SET")")
//                }
////                node.geometry?.materials = [newMaterial]
//            }
            
            
            var textNode: SCNNode?
            for hitResult in hitResults {
                if let foundNode = findNode(named: "TextNode", in: hitResult.node) {
                    textNode = foundNode
                    break
                }
            }

            if let textNode = textNode {
                print("User clicked preexisting annotation")
//                let alertController = UIAlertController(title: "Delete this step?", message: nil, preferredStyle: .alert)
//                let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
//                    textNode.removeFromParentNode()
//                }
//                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
//                alertController.addAction(yesAction)
//                alertController.addAction(noAction)
//                viewCtl?.present(alertController, animated: true, completion: nil)
            } else if let cubeFillNode = hitResults.first(where: { $0.node.name == "CubeFill" }) {
                print("Found a node named CubeFill!")
                
                let hitNode = cubeFillNode.node
                addAnnotation(node: hitNode)
                
                // Highlight selected cube
    //            let material = SCNMaterial()
    //            material.diffuse.contents = UIColor(red:1.0, green:0.9, blue:0.9, alpha:0.7)
    //            material.lightingModel = .constant
    //            material.isDoubleSided = true
    //            if let geometry = cubeFillNode.node.geometry, let material = geometry.firstMaterial {
    //                material.diffuse.contents = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    //            }
            } else {
                print("No node named CubeFill in hitResults.")
            }
        }
    }
    
    func getStepNumberText(initNumber: Int, completionHandler: @escaping (Bool, String?) -> Void) {
//        let alertController = UIAlertController(title: "Add step number?", message: nil, preferredStyle: .alert)
//        alertController.addTextField { textField in
//            textField.placeholder = "\(initNumber)"
//        }
//        
//        let addTextAction = UIAlertAction(title: "Add Number", style: .default) { _ in
//            let userInput = alertController.textFields?.first?.text
//            completionHandler(true, userInput)
//        }
//        
//        let noTextAction = UIAlertAction(title: "No Number", style: .default) { _ in
//            completionHandler(true, nil)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)  { _ in
//            completionHandler(false, nil)
//        }
//    
//        alertController.addAction(addTextAction)
//        alertController.addAction(noTextAction)
//        alertController.addAction(cancelAction)
//        
//        viewCtl?.present(alertController, animated: true, completion: nil)
    }
    
    func getAnnotationText(completionHandler: @escaping (Bool, String?) -> Void) {
//        let alertController = UIAlertController(title: "Add text to step?", message: nil, preferredStyle: .alert)
//        alertController.addTextField { textField in
//            textField.placeholder = "Step text"
//        }
//        
//        let addTextAction = UIAlertAction(title: "Add Text", style: .default) { _ in
//            let userInput = alertController.textFields?.first?.text
//            completionHandler(true, userInput)
//        }
//        
//        let noTextAction = UIAlertAction(title: "No Text", style: .default) { _ in
//            completionHandler(true, nil)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)  { _ in
//            completionHandler(false, nil)
//        }
//    
//        alertController.addAction(addTextAction)
//        alertController.addAction(noTextAction)
//        alertController.addAction(cancelAction)
//        
//        viewCtl?.present(alertController, animated: true, completion: nil)
    }
    
    func addAnnotation(node: SCNNode) {
        getStepNumberText(initNumber: (self.manyAnnotations+1)) { createAnnotation1, stepNumberText in
            if(createAnnotation1) {
                self.getAnnotationText() { createAnnotation, annotationText in
                    if(createAnnotation) {
                        self.manyAnnotations += 1
//                        addAnnotation(node: node, stepNumberText: stepNumberText, annotationText: annotationText)
                    }// if(createAnnotation)
                }// self.getAnnotationText()
            }// if(createAnnotation1)
        }// getStepNumberText()
    }// func
    
    func addAnnotation(node: SCNNode, stepNumberText: String, annotationText: String) {
        // Step # text node
        let textGeometry = SCNText(string: stepNumberText, extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 6)
        textGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        let midX = (textGeometry.boundingBox.max.x + textGeometry.boundingBox.min.x) * 0.5
        let midY = (textGeometry.boundingBox.max.y + textGeometry.boundingBox.min.y) * 0.5
        textNode.pivot = SCNMatrix4MakeTranslation(midX, midY, 0)
        textNode.name = "TextNode"
        
        // Text background shape
        let circleDiameter = CGFloat(max(textGeometry.boundingBox.max.x - textGeometry.boundingBox.min.x,
                                         textGeometry.boundingBox.max.y - textGeometry.boundingBox.min.y) * 1.5)  // Adjust as needed
        let circleGeometry = SCNPlane(width: circleDiameter, height: circleDiameter)
        circleGeometry.cornerRadius = 1
        circleGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        let circleNode = SCNNode(geometry: circleGeometry)
        circleNode.position = SCNVector3(x: midX, y: midY, z: 0.1)
        
        // Add constraints so annotation nodes always face camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        textNode.constraints = [billboardConstraint]
        circleNode.constraints = [billboardConstraint]
        
        // Center text node on parent node
        let min = textNode.boundingBox.min
        let max = textNode.boundingBox.max
        textNode.pivot = SCNMatrix4MakeTranslation(
            (max.x - min.x) / 2 + min.x,
            (max.y - min.y) / 2 + min.y,
            (max.z - min.z) / 2 + min.z
        )
        textNode.position = SCNVector3(0, 0, 0)

        node.addChildNode(textNode)
        textNode.addChildNode(circleNode)
        
        if(annotationText != nil) {
            let annotationTextGeometry = SCNText(string: annotationText, extrusionDepth: 1)
            annotationTextGeometry.font = UIFont.systemFont(ofSize: 2)
            annotationTextGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
            let annotationTextNode = SCNNode(geometry: annotationTextGeometry)
            annotationTextNode.name = "AnnotationTextNode"
            
            let width = CGFloat((annotationTextGeometry.boundingBox.max.x - annotationTextGeometry.boundingBox.min.x) + 2)
            let height = CGFloat((annotationTextGeometry.boundingBox.max.y - annotationTextGeometry.boundingBox.min.y) + 2)
            let circleGeometry = SCNPlane(width: width, height: height)
            circleGeometry.cornerRadius = 0.5
            circleGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
            let annotationCircleNode = SCNNode(geometry: circleGeometry)
            
            let textHeight = textNode.boundingBox.max.y - textNode.boundingBox.min.y
            let annotationTextHeight = annotationTextNode.boundingBox.max.y - annotationTextNode.boundingBox.min.y

            let midX = (annotationTextNode.boundingBox.max.x + annotationTextNode.boundingBox.min.x) * 0.5
            let midY = (annotationTextNode.boundingBox.max.y + annotationTextNode.boundingBox.min.y) * 0.5
            annotationCircleNode.position = SCNVector3(x: midX, y: midY, z: 0.1)
//                annotationTextNode.pivot = SCNMatrix4MakeTranslation(midX, midY, 0)
            
            
            // Adjusting the y position of the annotationTextNode to be just below textNode
            let offset: Float = 0.0
//                annotationTextNode.position.x = -midX
            annotationTextNode.position.y = -textHeight / 2 - annotationTextHeight / 2 - offset

            
            annotationTextNode.addChildNode(annotationCircleNode)
            textNode.addChildNode(annotationTextNode)
        }// if(annotationText != nil)
    }
    
    func getPoints() -> [SIMD3<Float>] {
        return referenceObjectPointCloud.points
    }
    
    func getCenter() -> SIMD3<Float> {
        return self.center
    }
}

extension SCNNode {
    func findChildNode(near position: SCNVector3, within delta: Float) -> SCNNode? {
        // Compute the distance between this node's position and the target position
        let distance = sqrt(pow(self.position.x - position.x, 2) +
                            pow(self.position.y - position.y, 2) +
                            pow(self.position.z - position.z, 2))
        
        // Check if the distance is within the delta
        if distance <= delta {
            return self
        }
        
        // Recursively search child nodes
        for child in childNodes {
            if let found = child.findChildNode(near: position, within: delta) {
                return found
            }
        }
        
        // If not found, return nil
        return nil
    }
}

