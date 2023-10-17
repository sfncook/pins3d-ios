import SceneKit

class PinCursorNode: SCNNode {

    var size = 0.1
    static let darkPurple = UIColor(red: 0.412, green: 0.475, blue: 0.753, alpha: 1.0)
    
    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let symbol = UIImage(systemName: "pin.fill")!
            .withTintColor(PinCursorNode.darkPurple)
        let material = SCNMaterial()
        material.diffuse.contents = symbol
        
        let plane = SCNPlane(width: 0.1, height: 0.1)  // Adjust the size as needed
        plane.materials = [material]

        let node = SCNNode(geometry: plane)
        self.addChildNode(node)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        self.constraints = [billboardConstraint]
    }
}
