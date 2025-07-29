import SpriteKit
import GameplayKit

/// Mini‑golf course with a wooden border (bounces) surrounded by water (blue background).
/// Drag backwards from the ball to shoot. The camera follows the ball.
class GameScene: SKScene {
    private var winShown = false
    private let course: Course
    
    init(course: Course, size: CGSize) {
           self.course = course
           super.init(size: size)
           anchorPoint = CGPoint(x: 0.5, y: 0.5)   // centre-origin simplifies math
       }
       required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Nodes
    private var ball = SKShapeNode(circleOfRadius: 10)
    private var hole = SKShapeNode(circleOfRadius: 14)
    private var aimLine: SKShapeNode?
    private var courseNode: SKShapeNode!      // green fairway with brown border
    private var touchStart: CGPoint?
    
    // MARK: - Tuning
    private let stopVelocity: CGFloat = 10     // pts/s
    private let borderWidth: CGFloat = 20      // visual + physics thickness

    // MARK: - Physics categories
    private struct Cat {
        static let ball: UInt32  = 0x1 << 0
        static let hole: UInt32  = 0x1 << 1
        static let border: UInt32 = 0x1 << 2
    }

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        print("✅ GameScene didMove: size =", size, "anchor:", anchorPoint)

        // Water outside the course
        backgroundColor = .systemBlue
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Build the rectangular fairway inset from screen edges
        buildCourse()
        placeBallAndHole()

        // Simple follow‑camera
        let cam = SKCameraNode()
        camera = cam
        addChild(cam)
    }

    // MARK: - Course
    private func buildCourse() {
           let builder = CourseBuilder()
           courseNode = builder.addCourse(to: self,
                                          spec: course,
                                          catBorder: Cat.border)
           
//        // ❶ desired green size
//        let courseSize = CGSize(width: 1200, height: 800)
//
//        // ❷ centre it in the scene
//        let fairwayRect = CGRect(
//            origin: CGPoint(x: frame.midX - courseSize.width  / 2,
//                            y: frame.midY - courseSize.height / 2),
//            size: courseSize)
//
//        // Green interior & brown wooden border
//        let path = CGPath(roundedRect: fairwayRect, cornerWidth: 16, cornerHeight: 16, transform: nil)
//        courseNode = SKShapeNode(path: path)
//        courseNode.fillColor   = .systemGreen
//        courseNode.strokeColor = .brown
//        courseNode.lineWidth   = borderWidth
//        addChild(courseNode)
//
//        // Physics edge (uses inner edge so the ball never clips into the paint)
//        let innerRect = fairwayRect.insetBy(dx: borderWidth/2, dy: borderWidth/2)
//        courseNode.physicsBody = SKPhysicsBody(edgeLoopFrom: innerRect)
//        courseNode.physicsBody?.categoryBitMask = Cat.border
//        courseNode.physicsBody?.restitution = 0.6     // bounce factor
    }

    // MARK: - Ball & hole
    private func placeBallAndHole() {
        // Ball
        ball.name = "ball"
        ball.fillColor = .white
        ball.strokeColor = .lightGray
//        ball.position = CGPoint(x: frame.midX - 100, y: frame.midY)
        ball.position = course.ballStart
        let ballBody = SKPhysicsBody(circleOfRadius: 10)
        ballBody.restitution   = 0.6
        ballBody.friction      = 0.3
        ballBody.linearDamping = 0.4
        ballBody.categoryBitMask = Cat.ball
        ballBody.collisionBitMask = Cat.border
        ballBody.contactTestBitMask = Cat.hole
        ball.physicsBody = ballBody
        addChild(ball)

        // Hole
        hole.name = "hole"
        hole.fillColor = .black
        hole.strokeColor = .black
//        hole.position = CGPoint(x: frame.midX + 150, y: frame.midY)
        hole.position = course.cupPosition
        let holeBody = SKPhysicsBody(circleOfRadius: 14)
        holeBody.isDynamic = false
        holeBody.categoryBitMask = Cat.hole
        holeBody.collisionBitMask = 0
        hole.physicsBody = holeBody
        addChild(hole)
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
//        print("Ball pos:", ball.position, "Camera pos:", camera?.position ?? .zero)

        guard let v = ball.physicsBody?.velocity else { return }
        if hypot(v.dx, v.dy) < stopVelocity {
            ball.physicsBody?.velocity = .zero
            ball.physicsBody?.angularVelocity = 0
        }
        if !winShown {
            camera?.position = ball.position
        }
    }

    // MARK: - Touch Handling (drag‑to‑shoot)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        touchStart = t.location(in: self)
        aimLine?.removeFromParent()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = touchStart, let t = touches.first else { return }
        drawAimLine(from: start, to: t.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = touchStart, let t = touches.first else { return }
        aimLine?.removeFromParent()
        let end = t.location(in: self)
        let impulse = CGVector(dx: start.x - end.x, dy: start.y - end.y)
        ball.physicsBody?.applyImpulse(impulse)
        touchStart = nil
    }

    private func drawAimLine(from start: CGPoint, to end: CGPoint) {
        aimLine?.removeFromParent()
        let p = CGMutablePath(); p.move(to: start); p.addLine(to: end)
        let line = SKShapeNode(path: p)
        line.strokeColor = .white; line.lineWidth = 2
        aimLine = line; addChild(line)
    }
}

// MARK: - Contacts
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ c: SKPhysicsContact) {
        let names = [c.bodyA.node?.name, c.bodyB.node?.name]
        if !winShown && names.contains("ball") && names.contains("hole") {
            winShown = true
            ball.removeFromParent();
            centerCamereOnHole()
        }
    }
    
    private func centerCamereOnHole() {
        guard let cam = camera else { return }
        
        let move = SKAction.move(to: hole.position, duration: 0.6)
        move.timingMode = .easeInEaseOut
        
        cam.run(move) { [weak self] in self?.showWinLabel()}
    }

    private func showWinLabel() {
        let label = SKLabelNode(text: "Hole in One!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 42
        label.fontColor = .yellow
        label.position  = CGPoint(x: 0, y: 120)
        camera?.addChild(label)
    }
}
