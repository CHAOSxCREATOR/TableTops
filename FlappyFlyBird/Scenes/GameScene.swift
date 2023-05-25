//
//  GameScene.swift
//  FlappyFlyBird
//
//  Created by Astemir Eleev on 02/05/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    // MARK: - Constants
    typealias PlayableCharacter = (PhysicsContactable & Updatable & Touchable & Playable & SKNode)
    var playerCharacter: PlayableCharacter?
    //
    
    static var viewportSize: CGSize = .zero
    
    // MARK: - Properties
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        PlayingState(adapter: sceneAdapeter!),
        GameOverState(scene: sceneAdapeter!),
        PausedState(scene: self, adapter: sceneAdapeter!)
        ])
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0

    var sceneAdapeter: GameSceneAdapter?
    let selection = UISelectionFeedbackGenerator() 
    // MARK: - Lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.lastUpdateTime = 0
        sceneAdapeter = GameSceneAdapter(with: self)
        sceneAdapeter?.stateMahcine = stateMachine
        sceneAdapeter?.stateMahcine?.enter(PlayingState.self)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        GameScene.viewportSize = view.bounds.size
        
        let pressed:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        pressed.delegate = self
        pressed.minimumPressDuration = 0.3
        view.addGestureRecognizer(pressed)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("LongPress BEGAN detected")
            // TODO:
            // 1. Object nya terus2an naik ga turun2 nunggu long press nya ended
            
        }
        if sender.state == .ended {
            print("LongPress ENDED detected")
            
            // TODO:
            // 1. Baru gravity nya main untuk nurunin si karakter nya
//            sceneAdapeter?.stateMahcine?.currentState = .some()
            
//            let gravity = UIGravityBehavior(items: [playerCharacter])
//            gravity.magnitude = 1.0  // Menentukan kecepatan jatuh
//            gravity.angle = CGFloat.pi / 2.0  // Menentukan sudut jatuh
//
//            // Mendapatkan referensi ke animator yang sedang digunakan pada tampilan
//            guard let animator = sender.view?.window?.rootViewController?.view.animator() else {
//                return
//            }
//
//            animator.addBehavior(gravity)
        
//        }
        }
    }
    
    // MARK: - Interaction handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach({ touchable in
            touchable.touchesBegan(touches, with: event)
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneAdapeter?.touchables.forEach { touchable in
            touchable.touchesCancelled(touches, with: event)
        }
    }
    
    // MARK: - Updates
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Don't perform any updates if the scene isn't in a view.
        guard view != nil else { return }
        
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTime
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTime = currentTime
        
        // Don't evaluate any updates if the `worldNode` is paused. Pausing a subsection of the node tree allows the `camera` and `overlay` nodes to remain interactive.
        if self.isPaused { return }
        
        // Updateh state machine
        stateMachine.update(deltaTime: deltaTime)

        // Update all the updatables
        sceneAdapeter?.updatables.filter({ return $0.shouldUpdate }).forEach({ (activeUpdatable) in
            activeUpdatable.update(currentTime)
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //TEMP
    
}


// MARK: - Conformance to ButtonNodeResponderType
extension GameScene: ButtonNodeResponderType {
    
    func buttonTriggered(button: ButtonNode) {
        guard let identifier = button.buttonIdentifier else {
            return
        }
        selection.selectionChanged()
        
        switch identifier {
        case .pause:
            sceneAdapeter?.stateMahcine?.enter(PausedState.self)
        case .resume:
            sceneAdapeter?.stateMahcine?.enter(PlayingState.self)
        case .home:
            let sceneId = Scenes.title.getName()
            guard let gameScene = GameScene(fileNamed: sceneId) else {
                return
            }
            gameScene.scaleMode = RoutingUtilityScene.sceneScaleMode
            let transition = SKTransition.fade(withDuration: 1.0)
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            self.view?.presentScene(gameScene, transition: transition)
        case .retry:
            // Reset and enter PlayingState
            sceneAdapeter?.stateMahcine?.enter(PlayingState.self)
        default:
            // Cannot be executed from here
            debugPrint("Cannot be executed from here")
            
        }
    }
}
