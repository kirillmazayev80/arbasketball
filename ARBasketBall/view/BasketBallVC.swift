//
//  ViewController.swift
//  ARBasketBall
//
//  Created by Kirill Mazaev on 24.07.2019.
//  Copyright © 2019 mazaev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class BasketBallVC: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopBtn: UIButton!
    
    fileprivate var currentNode: SCNNode!
    fileprivate let hoopScene = "art.scnassets/hoop.scn"
    fileprivate let backboardNode = "backboard"
    fileprivate let ballSkin = "basketballSkin.png"
    
    
    // MARK - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set new scene
        setScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK - Custom
    // setting min scene
    fileprivate func setScene() {
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // register gesture recognizer
        // by tapping on screen should appear a ball
        // and it will flight into backboard's hoop
        registerGestureRecognizer()
    }
    
    // MARK - Backboard
    // adding backboard on screen
    fileprivate func addBackBoardOnScreen() {
        guard let backBoardScene = SCNScene(named: hoopScene) else { return }
        guard let backboardNode = backBoardScene.rootNode.childNode(withName: backboardNode, recursively: false) else { return }
        
        // set physics body to the backboard
        backboardNode.position = SCNVector3.init(0, 0.5, -3)
        let options = [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: options)
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody
        
        // add backboard on screen
        sceneView.scene.rootNode.addChildNode(backboardNode)
        currentNode = backboardNode
    }
    
    // define horizontal moving of backboard
    func horizontalBackboardAction(node: SCNNode) {
        // define left and right backboard movings in horizontal plane
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        // set movings in overall horizontal moving sequence
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        // run movings sequence of backboard four times
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }
    
    func roundBackboardAction(node: SCNNode) {
        // // define up left, down right, down left, up right backboard movings in vertical plane
        let upLeftAction = SCNAction.move(by: SCNVector3(x: 1,  y: 1, z: 0), duration: 2)
        let downRightAction = SCNAction.move(by: SCNVector3(x: 1,  y: -1, z: 0), duration: 2)
        let downLeftAction = SCNAction.move(by: SCNVector3(x: -1,  y: -1, z: 0), duration: 2)
        let upRightAction = SCNAction.move(by: SCNVector3(x: -1,  y: 1, z: 0), duration: 2)
        // set movings in overall round moving sequence
        let actionSequence = SCNAction.sequence([upLeftAction, downRightAction, downLeftAction, upRightAction])
        // run movings sequence of backboard two times
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    // registing ball throwing tap gesture
    func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    // handling ball throwing tap gesture
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        guard let sceneView = gestureRecognizer.view as? ARSCNView else { return }
        guard let centerPoint = sceneView.pointOfView else { return }
        
        // calculation of camera position coordinates
        let cameraTransform = centerPoint.transform
        // camera location coordinates
        let cameraLocation = SCNVector3(x: cameraTransform.m41,
                                        y: cameraTransform.m42,
                                        z: cameraTransform.m43)
        // camera orientation coordinates
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31,
                                           y: -cameraTransform.m32,
                                           z: -cameraTransform.m33)
        // camera position coordinates
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x,
                                            cameraLocation.y + cameraOrientation.y,
                                            cameraLocation.z + cameraOrientation.z)
        // adding ball on screen
        addBallOnScreen(cameraPosition)
    }
    
    // adding ball on screen
    fileprivate func addBallOnScreen(_ cameraPosition: SCNVector3) {
        // create ball from sphere shape
        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: ballSkin)
        ball.materials = [material]
        // create ball scene node
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        
        // create ball physics body
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        ballNode.physicsBody = physicsBody
        
        // define ball throwing action
        let forceVector: Float = 6
        let forcedVector = SCNVector3(x: forceVector * cameraPosition.x,
                                      y: forceVector * cameraPosition.y,
                                      z: forceVector * cameraPosition.z)
        ballNode.physicsBody?.applyForce(forcedVector, asImpulse: true)
        // add ball scene node on screen
        sceneView.scene.rootNode.addChildNode(ballNode)
    }

    // MARK - Actions
    // add hoop on screen
    @IBAction fileprivate func addHoopAction(_ sender: Any) {
        addBackBoardOnScreen()
        addHoopBtn.isHidden = true
    }
    
    // perform round moving of the hoop
    @IBAction fileprivate func startRoundAction(_ sender: Any) {
        roundBackboardAction(node: currentNode)
    }
    
    // stopping all actions
    @IBAction fileprivate func stopAllActions(_ sender: Any) {
        currentNode.removeAllActions()
    }
    
    // perform horizontal moving of the hoop
    @IBAction fileprivate func startHorizontalAction(_ sender: Any) {
        horizontalBackboardAction(node: currentNode)
    }
    
}
