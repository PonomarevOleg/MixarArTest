import UIKit
import SceneKit
import ARKit
import AVKit
import Vision

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let cubeCategory = CollisionCategory(rawValue: 1 << 0)
    static let coinCategory = CollisionCategory(rawValue: 1 << 1)
}

class ViewController: UIViewController, ARSessionDelegate, SCNPhysicsContactDelegate {
    private var player: AVAudioPlayer?
    private var cubeState = 0
    private var models = 0
    private var didInitializeScene: Bool = false
    private var sceneController = ModelScene()
    
    @IBOutlet weak var coinButton: UIButton!
    @IBOutlet private weak var countNameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var upButtonImageView: UIImageView!
    @IBOutlet private weak var leftButtonImageView: UIImageView!
    @IBOutlet private weak var rightButtonImageView: UIImageView!
    @IBOutlet private weak var downButtonImageView: UIImageView!
    @IBOutlet weak var sceneView: ARSCNView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupUI()
        addGesture()
        startObjectDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTracking()
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - IBAction
    /// управление движением кубиков
    @IBAction private func upButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveUp()
            }
        })
    }
    @IBAction private func rightButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveRight()
            }
        })
    }
    @IBAction private func downButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveDown()
                
            }
        })
    }
    @IBAction private func leftButtonTap(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cubeNode = node as? Cube {
                cubeNode.moveLeft()
            }
        })
    }
    /// добавление монет
    @IBAction private func addCoinsButton(_ sender: Any) {
        sceneController.scene?.rootNode.enumerateChildNodes({ (node, _) in
            if let cube = node as? Cube {
                let randomBool = Bool.random()
                if randomBool {
                    sceneController.addCoins(
                        position: SCNVector3(
                            x: cube.position.x,
                            y: cube.position.y + 0.1,
                            z: cube.position.z
                        )
                    )
                }
            }
        })
    }

    // MARK: - Private functions
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        let referenceImage = ARReferenceImage.referenceImages(
            inGroupNamed: "marker",
            bundle: nil
        )
        configuration.detectionImages = referenceImage
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupScene() {
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.delegate = self
        sceneView.showsStatistics = true
        if let scene = sceneController.scene {
            sceneView.scene = scene
        }
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    private func addGesture() {
        sceneView.session.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressScreen))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    /// изменение цвета и создание кубиков
    @objc private func didTapScreen(recognizer: UITapGestureRecognizer) {
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
    @objc private func longPressScreen(recognizer: UILongPressGestureRecognizer) {
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
    /// Распознавание изображния
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.global().async {
            
            let position = SCNVector3(imageAnchor.transform.columns.3.x, imageAnchor.transform.columns.3.y, imageAnchor.transform.columns.3.z + 0.5)
            print("Image found")
            let cube = Cube()
            cube.position = position
            self.sceneController.addModel(modelName: "crystal.dae", position: position)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !didInitializeScene {
            if sceneView.session.currentFrame?.camera != nil {
                didInitializeScene = true
            }
        }
    }
}
    // MARK: - Cube color controll
extension ViewController {
    private func changeBoxColor(cube: SCNNode) {
        cubeState += 1
        if cubeState > 4 {
            cubeState = 0
        }
        
        switch cubeState {
        case 0 : colorChange(color: .green, cube: cube)
        case 1 : colorChange(color: .yellow, cube: cube)
        case 2 : colorChange(color: .magenta, cube: cube)
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
    
    // MARK: - Visibility control
extension ViewController {
    private func showButtons() {
        countLabel.isHidden = false
        countNameLabel.isHidden = false
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
        countLabel.isHidden = true
        countNameLabel.isHidden = true
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
    /// настройка UI
    private func setupUI() {
        checkModels()
        countLabel.text = String(0)
        downButtonImageView.transform = downButtonImageView.transform.rotated(by: .pi)
        leftButtonImageView.transform = leftButtonImageView.transform.rotated(by: .pi * 1.5)
        rightButtonImageView.transform = rightButtonImageView.transform.rotated(by: .pi / 2)
        coinButton.setTitle("", for: .normal)
        leftButton.setTitle("", for: .normal)
        rightButton.setTitle("", for: .normal)
        upButton.setTitle("", for: .normal)
        downButton.setTitle("", for: .normal)
    }
}

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func startObjectDetection() {
        let captureSession = AVCaptureSession()
        let dataOutput = AVCaptureVideoDataOutput()
        guard let captureDevice = AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera is ready to detect", Date())
    }
}

    // MARK: - AR Models Collision
extension ViewController {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Collision happened")
        
        if contact.nodeA.physicsBody?.contactTestBitMask == CollisionCategory.coinCategory.rawValue {
            contact.nodeA.removeFromParentNode()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.playSound(sound: "coin", format: "wav")
                if let countText = self.countLabel.text {
                    if let count = Int(countText) {
                        self.countLabel.text = String(count + 1)
                    }
                }
                self.view.layoutIfNeeded()
            }
        }
        
        if contact.nodeB.physicsBody?.contactTestBitMask == CollisionCategory.coinCategory.rawValue {
            contact.nodeB.removeFromParentNode()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.playSound(sound: "coin", format: "wav")
                if let countText = self.countLabel.text {
                    if let count = Int(countText) {
                        self.countLabel.text = String(count + 1)
                    }
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}

    // MARK: - Sounds
extension ViewController {
    func playSound(sound : String, format: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: format) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

