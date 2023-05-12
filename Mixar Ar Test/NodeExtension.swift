import SceneKit

extension SCNNode {
    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
            objScene.rootNode.enumerateChildNodes({ (node, _) in
                let body = SCNPhysicsBody(type: .static, shape: nil)
                node.physicsBody = body
                node.physicsBody?.categoryBitMask = CollisionCategory.coinCategory.rawValue
                node.physicsBody?.collisionBitMask = CollisionCategory.cubeCategory.rawValue
                nodesInFile.append(node)
            })
        } catch {}
        return nodesInFile
    }
    
    func topmost(parent: SCNNode? = nil, until: SCNNode) -> SCNNode {
        if let pNode = self.parent {
            return pNode == until ? self : pNode.topmost(parent: pNode, until: until)
        } else {
            return self
        }
    }
}
