import Foundation
import SceneKit

class SceneObject: SCNNode {
    override init() {
        super.init()
        
        let cubeNode = SCNNode()
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.03)
        
        let colors = [UIColor.green,
                      UIColor.green,
                      UIColor.green,
                      UIColor.green,
                      UIColor.green,
                      UIColor.green]
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        box.materials = sideMaterials
        cubeNode.geometry = box
        let body = SCNPhysicsBody(type: .static, shape: nil)
        cubeNode.physicsBody = body
        cubeNode.physicsBody?.categoryBitMask = CollisionCategory.cubeCategory.rawValue
        cubeNode.physicsBody?.collisionBitMask = CollisionCategory.coinCategory.rawValue
        self.addChildNode(cubeNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Cube: SceneObject {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveRight() {
        let moveRight = SCNAction.moveBy(x: 0.2, y: 0, z: 0, duration: 0.5)
        runAction(moveRight)
    }
    
    func moveLeft() {
        let moveLeft = SCNAction.moveBy(x: -0.2, y: 0, z: 0, duration: 0.5)
        runAction(moveLeft)
    }
    
    func moveUp() {
        let moveUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 0.5)
        runAction(moveUp)
    }
    
    func moveDown() {
        let moveDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 0.5)
        runAction(moveDown)
    }
}

class ModelObject: SCNNode {
    init(from file: String) {
        super.init()
        let nodesInFile = SCNNode.allNodes(from: file)
        nodesInFile.forEach { (node) in
            self.addChildNode(node)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Coin: ModelObject {
    init() {
        super.init(from: "Coin.dae")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startRotaing() {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 5.0)
            let hoverUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 2.5)
            let hoverDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 2.5)
            let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
            let rotateAndHover = SCNAction.group([rotateOne, hoverSequence])
            let repeatForever = SCNAction.repeatForever(rotateAndHover)
            runAction(repeatForever)
    }
}
