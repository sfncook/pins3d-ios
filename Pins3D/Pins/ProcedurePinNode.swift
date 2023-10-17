import SceneKit

class ProcedurePinNode: SCNNode {
    static let typeName = "ProcedurePinNode"
    let procedurePin: ProcedurePin
    var backgroundNode: SCNNode?
    
    init(_ procedurePin: ProcedurePin) {
        self.procedurePin = procedurePin
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let annotationTextGeometry = SCNText(string: "(P) \(self.procedurePin.text ?? "NOT SET")", extrusionDepth: 1)
        annotationTextGeometry.font = UIFont.systemFont(ofSize: 2)
        annotationTextGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
        let annotationTextNode = SCNNode(geometry: annotationTextGeometry)
        
        let width = CGFloat((annotationTextGeometry.boundingBox.max.x - annotationTextGeometry.boundingBox.min.x) + 2)
        let height = CGFloat((annotationTextGeometry.boundingBox.max.y - annotationTextGeometry.boundingBox.min.y) + 2)
        let backgroundGeometry = SCNPlane(width: width, height: height)
        backgroundGeometry.cornerRadius = 0.5
        backgroundGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        let backgroundNode = SCNNode(geometry: backgroundGeometry)
        
        let midX = (annotationTextNode.boundingBox.max.x + annotationTextNode.boundingBox.min.x) * 0.5
        let midY = (annotationTextNode.boundingBox.max.y + annotationTextNode.boundingBox.min.y) * 0.5
        backgroundNode.position = SCNVector3(x: midX, y: midY, z: 0.1)

        annotationTextNode.addChildNode(backgroundNode)
        self.addChildNode(annotationTextNode)
        self.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        self.constraints = [billboardConstraint]
        
        self.name = ProcedurePinNode.typeName
        self.backgroundNode = backgroundNode
    }
    
    func addHighlight() {
        // Increase the border width by scaling the node down slightly
        backgroundNode?.scale = SCNVector3(0.9, 0.9, 1.0)
        
        // Change the color to make it stand out more (optional)
        if let geometry = backgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Setting to red for example
        }
    }

    func removeHighlight() {
        // Reset the scale to the original
        backgroundNode?.scale = SCNVector3(1.0, 1.0, 1.0)
        
        // Reset the color to its original state
        if let geometry = backgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        }
    }
    
}

