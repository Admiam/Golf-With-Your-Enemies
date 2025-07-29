//
//  CourseBuilder.swift
//  GolfWithYourEnemies
//
//  Created by Adam Míka on 29.07.2025.
//

import SpriteKit

struct CourseBuilder {

    let borderWidth: CGFloat = 20
    let bounce: CGFloat      = 0.6

    func addCourse(to scene: SKScene, spec: Course,
                   catBorder: UInt32) -> SKShapeNode {

        // 1. Rectangle path centred on scene (anchorPoint == .5)
        let rect = CGRect(origin: CGPoint(x: -spec.size.width/2,
                                          y: -spec.size.height/2),
                          size: spec.size)
        let path = CGPath(roundedRect: rect,
                          cornerWidth: spec.corner,
                          cornerHeight: spec.corner,
                          transform: nil)

        // 2. Visual node
        let node = SKShapeNode(path: path)
        node.fillColor   = .systemGreen
        node.strokeColor = .brown
        node.lineWidth   = borderWidth
        scene.addChild(node)

        // 3. Physics edge on the inside of the border
        let inner = rect.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: inner)
        node.physicsBody?.categoryBitMask = catBorder
        node.physicsBody?.restitution     = bounce
        return node
    }
}
