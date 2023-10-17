import SceneKit

class StepPinNode: SCNNode {
    static let typeName = "StepPinNode"
    private let stepPin: StepPin
    
    init(_ stepPin: StepPin) {
        self.stepPin = stepPin
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let annotationTextGeometry = SCNText(string: "(\(self.stepPin.number)) \(self.stepPin.text ?? "NOT SET")", extrusionDepth: 1)
        annotationTextGeometry.font = UIFont.systemFont(ofSize: 2)
        annotationTextGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
        let annotationTextNode = SCNNode(geometry: annotationTextGeometry)
        annotationTextNode.name = StepPinNode.typeName
        
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
    }
    
}

