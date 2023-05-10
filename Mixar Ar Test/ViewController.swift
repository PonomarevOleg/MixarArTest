import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    private var cubeState = 0
    private var models = 0
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var upButtonImageView: UIImageView!
    @IBOutlet var leftButtonImageView: UIImageView!
    @IBOutlet var rightButtonImageView: UIImageView!
    @IBOutlet var downButtonImageView: UIImageView!
    var sceneController = ModelScene()
    
    @IBOutlet var sceneView: ARSCNView!
    
    var didInitializeScene: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupScene()
        addGesture()
    }
    
    @IBAction func upButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveUp()
            }
        })
    }
    @IBAction func rightButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveRight()
            }
        })
    }
    @IBAction func downButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveDown()
            }
        })
    }
    @IBAction func leftButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveLeft()
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        if let scene = sceneController.scene {
            sceneView.scene = scene
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func addGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressScreen))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    /// изменение цвета и создание кубиков
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if didInitializeScene, let camera = sceneView.session.currentFrame?.camera {
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation)
            if let node = hitTestResults.first?.node,
               let scene = sceneController.scene,
               let cube = node.topmost(until: scene.rootNode) as? Cube {
                changeBoxColor(cube: cube)
            }
            else {
                models += 1
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                let cube = Cube()
                cube.position = position
                sceneController.scene?.rootNode.addChildNode(cube)
                checkModels()
            }
        }
    }
    /// удаление кубика
    @objc func longPressScreen(recognizer: UILongPressGestureRecognizer) {
        models -= 1
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        if let node = hitTestResults.first?.node,
           let scene = sceneController.scene,
           let cube = node.topmost(until: scene.rootNode) as? Cube {
            cube.removeFromParentNode()
            checkModels()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !didInitializeScene {
            if sceneView.session.currentFrame?.camera != nil {
                didInitializeScene = true
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
}
/// Изменение цвета кубиков
extension ViewController {
    private func changeBoxColor(cube: SCNNode) {
        self.cubeState += 1
        if cubeState > 4 {
            cubeState = 0
        }
        
        switch cubeState {
        case 0 : colorChange(color: .green, cube: cube)
        case 1 : colorChange(color: .yellow, cube: cube)
        case 2 : colorChange(color: .yellow, cube: cube)
        case 3 : colorChange(color: .red, cube: cube)
        default: colorChange(color: .cyan, cube: cube)
        }
    }
    private func colorChange(color: UIColor, cube: SCNNode) {
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.03)
        let colors = [color,
                      color,
                      color,
                      color,
                      color,
                      color]
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        box.materials = sideMaterials
        cube.geometry = box
    }
}

extension ViewController {
    private func showButtons() {
        downButtonImageView.isHidden = false
        leftButtonImageView.isHidden = false
        rightButtonImageView.isHidden = false
        upButtonImageView.isHidden = false
        upButton.isHidden = false
        downButton.isHidden = false
        leftButton.isHidden = false
        rightButton.isHidden = false
    }
    
    private func hideButtons() {
        downButtonImageView.isHidden = true
        leftButtonImageView.isHidden = true
        rightButtonImageView.isHidden = true
        upButtonImageView.isHidden = true
        upButton.isHidden = true
        downButton.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
    }
    
    private func checkModels() {
        models != 0 ? showButtons() : hideButtons()
    }
    
    private func setupUI() {
        checkModels()
        downButtonImageView.transform = downButtonImageView.transform.rotated(by: .pi)
        leftButtonImageView.transform = leftButtonImageView.transform.rotated(by: .pi * 1.5)
        rightButtonImageView.transform = rightButtonImageView.transform.rotated(by: .pi / 2)
        leftButton.setTitle("", for: .normal)
        rightButton.setTitle("", for: .normal)
        upButton.setTitle("", for: .normal)
        downButton.setTitle("", for: .normal)
    }
}
