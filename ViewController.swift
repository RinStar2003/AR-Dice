//
//  ViewController.swift
//  ARDice
//
//  Created by мас on 19.10.2022.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var player: AVAudioPlayer?
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.delegate = self
        
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
        //        let sphere = SCNSphere(radius: 0.2)
        //
        //        let material = SCNMaterial()
        //
        //        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        //
        //        sphere.materials = [material]
        //
        //        let node = SCNNode()
        //
        //        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        //
        //        node.geometry = sphere
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
        //        // Create a new scene
        //        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //
        //        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        //
        //            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
        //
        //            sceneView.scene.rootNode.addChildNode(diceNode)
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first {
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        x: hitResults.worldTransform.columns.3.x,
                        y: hitResults.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResults.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    playSound(sound: "sound")
                    
                    roll(dice: diceNode)
                    
                }
            }
        }
    }
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            
            for dice in diceArray {
                roll(dice: dice)
            }
            
        }
        
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = (Float(arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        let randomZ = (Float(arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        dice.runAction(
        
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        
        )
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        playSound(sound: "sound")
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        playSound(sound: "end")
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    func playSound(sound: String) {
        guard let path = Bundle.main.path(forResource: sound, ofType: "mp3") else { return }
        
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            playSound(sound: "field")
            
            node.addChildNode(planeNode)
            
        } else {
            
            return
            
        }
    }
    
}
