import SceneKit

class StepPinNode: SCNNode {
    static let typeName = "StepPinNode"
    let stepPin: StepPin
    
    var numberTextGeometry: SCNText?
    var numberBackgroundNode: SCNNode?
    var summaryTextGeometry: SCNText?
    var textBackgroundNode: SCNNode?
    var outlineNode: SCNNode?
    
    private let defaultNumberTextColor = UIColor.white
    private let defaultNumberBgColor = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
    private let defaultSummaryTextColor = UIColor.white
    private let defaultSummaryBgColor = UIColor(red: 0.2588, green: 0.2824, blue: 0.4549, alpha: 1.0)
    
    private let highlightNumberTextColor = UIColor(red: 0.9765, green: 0.9020, blue: 0.6902, alpha: 1.0)
    private let highlightNumberBgColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
    private let highlightSummaryTextColor = UIColor.darkGray
    private let highlightSummaryBgColor = UIColor(red: 0.9765, green: 0.9020, blue: 0.6902, alpha: 1.0)
    
    init(_ stepPin: StepPin) {
        self.stepPin = stepPin
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let stepNumberStr = String(format: "%02d", self.stepPin.number)
        
        // Number text
        numberTextGeometry = SCNText(string: "\(stepNumberStr)", extrusionDepth: 1)
        numberTextGeometry!.font = UIFont.systemFont(ofSize: 3)
        numberTextGeometry!.firstMaterial?.diffuse.contents = defaultNumberTextColor
        let numberTextNode = SCNNode(geometry: numberTextGeometry!)

        // Number background
        let numberWidth = CGFloat((numberTextNode.boundingBox.max.x - numberTextNode.boundingBox.min.x) + 3)
        let numberHeight = CGFloat((numberTextNode.boundingBox.max.y - numberTextNode.boundingBox.min.y) + 3)
        let numberBackgroundGeometry = SCNPlane(width: numberWidth, height: numberHeight)
        numberBackgroundGeometry.cornerRadius = max(numberWidth, numberHeight)/2.0
        numberBackgroundGeometry.firstMaterial?.diffuse.contents = defaultNumberBgColor
        numberBackgroundNode = SCNNode(geometry: numberBackgroundGeometry)
        // Center background behind text
        numberBackgroundNode!.position = SCNVector3((numberWidth/2.0)-1.3, (numberHeight/2.0)-0.6, -0.1)
        numberTextNode.addChildNode(numberBackgroundNode!)
        
        // Number outline
        let outlineWidth = numberWidth + 0.1
        let outlineHeight = numberHeight + 0.1
        let outlineGeometry = SCNPlane(width: outlineWidth, height: outlineHeight)
        outlineGeometry.cornerRadius = max(outlineWidth, outlineHeight) / 2.0
        outlineGeometry.firstMaterial?.diffuse.contents = UIColor.white
        outlineNode = SCNNode(geometry: outlineGeometry)
        guard let outlineNode = outlineNode else {return}
        numberBackgroundNode!.addChildNode(outlineNode)
        outlineNode.position.z = -0.01 // Adjust the z position so that the outline
        
        // Summary text
        summaryTextGeometry = SCNText(string: self.stepPin.text ?? "NOT SET", extrusionDepth: 0.2)
        summaryTextGeometry!.font = UIFont.systemFont(ofSize: 1.5)
        summaryTextGeometry!.firstMaterial?.diffuse.contents = defaultSummaryTextColor
        let summaryTextNode = SCNNode(geometry: summaryTextGeometry)
        
        // Summary background
        let textWidth = CGFloat((summaryTextGeometry!.boundingBox.max.x - summaryTextGeometry!.boundingBox.min.x) + 4)
        let textHeight = CGFloat((summaryTextGeometry!.boundingBox.max.y - summaryTextGeometry!.boundingBox.min.y) + 2)
        let textBackgroundGeometry = SCNPlane(width: textWidth, height: textHeight)
        textBackgroundGeometry.cornerRadius = max(textWidth, textHeight) / 2.0
        textBackgroundGeometry.firstMaterial?.diffuse.contents = defaultSummaryBgColor
        textBackgroundNode = SCNNode(geometry: textBackgroundGeometry)
        // Center background behind text
        textBackgroundNode!.position = SCNVector3((textWidth/2.0)-2.0, (textHeight/2.0), -0.1)
        summaryTextNode.addChildNode(textBackgroundNode!)
        
        // Position both nodes around self
        numberTextNode.position = SCNVector3(-(numberWidth/2.0), ((numberHeight/2.0) + 0.25), 0)
        summaryTextNode.position = SCNVector3(-(textWidth/2.0), -((textHeight/2.0) + 0.25), 0)
        
//        let sphereNode = SCNNode(geometry: SCNSphere(radius: 1))
//        self.addChildNode(sphereNode)
        
        self.addChildNode(numberTextNode)
        self.addChildNode(summaryTextNode)
        self.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        self.constraints = [billboardConstraint]
        
        self.name = StepPinNode.typeName
//        self.numberBackgroundNode = numberBackgroundNode
//        self.textBackgroundNode = textBackgroundNode
    }
    
    func addHighlight() {
        if let geometry = numberTextGeometry {
            geometry.firstMaterial?.diffuse.contents = highlightNumberTextColor
        }
        if let geometry = numberBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = highlightNumberBgColor
        }
        if let geometry = summaryTextGeometry {
            geometry.firstMaterial?.diffuse.contents = UIColor.black
        }
        if let geometry = textBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = highlightSummaryBgColor
        }
        outlineNode?.isHidden = false
    }

    func removeHighlight() {
        if let geometry = numberTextGeometry {
            geometry.firstMaterial?.diffuse.contents = defaultNumberTextColor
        }
        if let geometry = numberBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = defaultNumberBgColor
        }
        if let geometry = summaryTextGeometry {
            geometry.firstMaterial?.diffuse.contents = defaultSummaryTextColor
        }
        if let geometry = textBackgroundNode?.geometry as? SCNPlane {
            geometry.firstMaterial?.diffuse.contents = defaultSummaryBgColor
        }
        outlineNode?.isHidden = true
    }
    
}

