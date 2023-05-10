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
