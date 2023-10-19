import SceneKit

class StepPinNode: SCNNode {
    static let typeName = "StepPinNode"
    let stepPin: StepPin
    var numberBackgroundNode: SCNNode?
    var backgroundNode: SCNNode?
    
    init(_ stepPin: StepPin) {
        self.stepPin = stepPin
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Number annotation
        let numberAnnotationGeometry = SCNText(string: "\(self.stepPin.number)", extrusionDepth: 1)
        numberAnnotationGeometry.font = UIFont.systemFont(ofSize: 2)
        numberAnnotationGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
        let numberAnnotationNode = SCNNode(geometry: numberAnnotationGeometry)

        let numberWidth = CGFloat((numberAnnotationNode.boundingBox.max.x - numberAnnotationNode.boundingBox.min.x) + 2)
        let numberHeight = CGFloat((numberAnnotationNode.boundingBox.max.y - numberAnnotationNode.boundingBox.min.y) + 2)
        let numberBackgroundGeometry = SCNPlane(width: numberWidth, height: numberHeight)
        numberBackgroundGeometry.cornerRadius = 0.5
        numberBackgroundGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        let numberBackgroundNode = SCNNode(geometry: numberBackgroundGeometry)
        
        numberBackgroundNode.position = SCNVector3((numberWidth/2.0)-1.0, (numberHeight/2.0), -0.1)
        numberAnnotationNode.addChildNode(numberBackgroundNode)
        
        // Text annotation
        let textAnnotationGeometry = SCNText(string: self.stepPin.text ?? "NOT SET", extrusionDepth: 0.2)
        textAnnotationGeometry.font = UIFont.systemFont(ofSize: 2)
        textAnnotationGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
        let textAnnotationNode = SCNNode(geometry: textAnnotationGeometry)
        
        let textWidth = CGFloat((textAnnotationGeometry.boundingBox.max.x - textAnnotationGeometry.boundingBox.min.x) + 2)
        let textHeight = CGFloat((textAnnotationGeometry.boundingBox.max.y - textAnnotationGeometry.boundingBox.min.y) + 2)
        let textBackgroundGeometry = SCNPlane(width: textWidth, height: textHeight)
        textBackgroundGeometry.cornerRadius = 0.5
        textBackgroundGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        let textBackgroundNode = SCNNode(geometry: textBackgroundGeometry)
        
        textBackgroundNode.position = SCNVector3((textWidth/2.0)-1.0, (textHeight/2.0), -0.1)
        textAnnotationNode.addChildNode(textBackgroundNode)
        
        // Position both nodes around self
        numberAnnotationNode.position = SCNVector3(-(numberWidth/2.0), ((numberHeight/2.0) + 0.25), 0)
        textAnnotationNode.position = SCNVector3(-(textWidth/2.0), -((textHeight/2.0) + 0.25), 0)
        
//        let sphereNode = SCNNode(geometry: SCNSphere(radius: 1))
//        self.addChildNode(sphereNode)
        
        self.addChildNode(numberAnnotationNode)
        self.addChildNode(textAnnotationNode)
        self.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        self.constraints = [billboardConstraint]
        
        self.name = StepPinNode.typeName
        self.numberBackgroundNode = numberBackgroundNode
        self.backgroundNode = textBackgroundNode
    }

    
    func addHighlight() {
        // Change the color to make it stand out more (optional)
        if let geometry = numberBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Setting to red for example
        }
        // Change the color to make it stand out more (optional)
        if let geometry = backgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Setting to red for example
        }
    }

    func removeHighlight() {
        // Reset the color to its original state
        if let geometry = numberBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        }
        // Reset the color to its original state
        if let geometry = backgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.8627, green: 0.8392, blue: 0.9686, alpha: 1.0)
        }
    }
    
}

