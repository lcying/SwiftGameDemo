//
//  GameScene.swift
//  FlappyBird_lcy
//
//  Created by lcy on 2018/5/24.
//  Copyright © 2018year lcy. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameStatus {
    case idle
    
    case running
    
    case over
}

let birdCategory: UInt32 = 0x1 << 0
let pipeCategory: UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2

class GameScene: SKScene {
    var gameStatus: GameStatus = .idle //游戏状态
    
    var floor1: SKSpriteNode! //两块地面轮流
    
    var floor2: SKSpriteNode!
    
    var bird: SKSpriteNode! //小鸟
    
    /*
     SKLabelNode是没有size这个属性的，他的frame属性也只是readonly的
     SKLabelNode有两个新的属性叫做verticalAlignmentMode和horizontalAlignmentMode，表示这个label在水平和垂直方向上如何布局，他们是枚举类型。比如你把的SKLabelNode的postion位置设置在(50,100)这个点，然后把他的verticalAlignmentMode 设置为.top，则表示这段文字的顶部是position所在位置的y的水平高度上，如果设置为.bottom，则这段文字的底部水平线高度就是position的y的水平高度。所以horizontalAlignmentMode属性也是同理，只是它是设置水平方向上的布局。
     */
    
    //游戏结束提示label
    lazy var gameOverLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Game Over"
        return label
    }()

    //飞行距离提示label
    lazy var metersLabel: SKLabelNode = {
        let label = SKLabelNode(text: "meters:0")
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        return label
    }()
    
    var meters = 0 {
        didSet {
            metersLabel.text = "meters:\(meters)"
        }
    }
    
    //didMove()方法会在当前场景被显示到一个view上的时候调用，你可以在里面做一些初始化的工作
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        //配置场景的物理 ---------------------------------
        
        //给场景添加一个物理体，限制游戏范围，其他物理体就不会跑出这个范围
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        //设置物理世界的碰撞检测代理
        self.physicsWorld.contactDelegate = self
        
        //设置物理世界的重力大小
        self.physicsWorld.gravity = CGVector(dx:0.0, dy:-1.0)
        
        /*
         要让floor向左移动，使得看起来小鸟在向右飞，所以弄了两个floor头尾两连地放着，等会让两个floor一起往左边移动，当左边的floor完全超出屏幕的时候，就马上把左边的floor移动凭借到右边的floor后面然后继续向左移动，如此循环下去
         
         将anchorPoint设置为(0,0)，即SpriteNode的左下角的点作为这个node的锚点，是为了方便定位floor
         
         SKScene场景的默认锚点为(0,0)即左下角，SKSpriteNode的默认锚点为(0.5,0.5)即它的中心点。
         
         另外SpriteKit的坐标系是向右x增加，向上y增加。而不像做iOS应用开发时候UIKit是向右x增加，向下y增加！
         */
        
        //放置地面
        floor1 = SKSpriteNode(imageNamed: "land")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.size = CGSize(width: self.size.width, height: 130)
        floor1.position = CGPoint(x: 0, y: 0)
        
        //配置地面物理体
        /*
         categoryBitMask:
         用来表示当前物理体是哪一个物理体，我们用我们刚刚准备好的floorCategory来表示他，等会碰撞检测的时候需要通过这个来判断。
         */
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
        floor1.physicsBody?.categoryBitMask = floorCategory
        
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "land")
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.size = CGSize(width: self.size.width, height: 130)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        
        
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
        floor2.physicsBody?.categoryBitMask = floorCategory
        addChild(floor2)
        
        //放置小鸟
        bird = SKSpriteNode(imageNamed:"bird-1")
        bird.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        //配置小鸟物理体
        
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        //禁止旋转
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdCategory
        //设置小鸟可以碰撞的物理体
        bird.physicsBody?.contactTestBitMask = floorCategory | pipeCategory
        bird.physicsBody?.isDynamic = false
        
        addChild(bird)
        

        metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
        /*
         我们把label在z轴上的位置设置在了100，你可能会问这不是2D游戏么怎么会有z轴，这里的z轴你也可以理解为图层的层次顺序轴，zPosition越大就越靠近玩家，就是说如果两个场景里的node某一部分重叠了，那么就是zPosition大的那个node会覆盖住小的那个node，zPosition默认值是0，如果两个都是0的node重叠了那就要看谁是先被添加进场景的，先被添加进的会被后添加进的覆盖住。
         */
        metersLabel.zPosition = 100
        
        addChild(metersLabel)
        
        
        //游戏初始化
        shuffle()
        
    }
    
    //update()方法为SKScene自带的系统方法，在画面每一帧刷新的时候就会调用一次
    override func update(_ currentTime: TimeInterval) {
        if gameStatus != .over {
            moveScene()
        }
        
        if gameStatus == .running {
            meters += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameStatus {
        case .idle:
            startGame()
        case .running:
//            print("给小鸟一个向上的力")
            /*
             Impluse是什么？
             Impulse在物理上就是冲量的意思，冲量=质量 * (结束速度 - 初始速度)，即I = m * (v2 - v1)，如果物体的质量为1，那么冲量i = v2 - v1。当一个质量为1的物理体applyImpulse(CGVector(dx: 0, dy: 20))的意思就是让他在y的方向上叠加20m/s的速度。当然如果物理体质量m不为1，那叠加的速度就不是刚好等于冲量的字面量了，而是要除以m了。如一个质量为2的物理体同样applyImpulse(CGVector(dx: 0, dy: 20))，结果就是它在y的方向上叠加了10m/s的一个速度
             */
            
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2))
        case .over:
            shuffle()
        }
    }
    
    // MARK: - methods -----------------------
    
    //游戏初始化
    func shuffle() {
        meters = 0
        gameStatus = .idle
        birdStartFly()
        //在每一局新开始的时候将上一局可能残留的旧水管删除
        removeAllPipesNode()
    }
    
    //游戏开始
    func startGame() {
        gameStatus = .running
        bird.physicsBody?.isDynamic = true
        //开始随机创建水管
        startCreateRandomPipesAction()
    }

    //游戏结束
    func gameOver() {
        gameStatus = .over
        birdStopFly()
        //停止创建水管
        stopCreateRandomPipesAction()
        
        isUserInteractionEnabled = false
        addChild(gameOverLabel)
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
        
        gameOverLabel.run(SKAction.move(by: CGVector(dx: 0, dy: -self.size.height * 0.5), duration: 0.5)) {
            //动画结束才允许用户点击屏幕
            self.isUserInteractionEnabled = true
        }
    }
    
    
    //让地面动起来
    func moveScene() {
        //让地面动起来
        floor1.position = CGPoint(x: floor1.position.x - 1, y: floor1.position.y)
        
        floor2.position = CGPoint(x: floor2.position.x - 1, y: floor2.position.y)
        
        //检查两块地面的位置
        
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x: floor2.position.x + floor2.size.width, y: floor1.position.y)
        }
        
        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x: floor1.position.x + floor1.size.width, y: floor2.position.y)
        }
        
        //让场景上存在的水管动起来
        //循环得到场景上所有水管node
        for pipeNode in self.children where pipeNode.name == "pipe" {
            //因为要用到pipe的size，而SKNode没有size属性，所以需要转换成SKSpriteNode
            if let pipeSprite = pipeNode as? SKSpriteNode {
                pipeSprite.position = CGPoint(x: pipeSprite.position.x - 1, y: pipeSprite.position.y)
                //当水管移动出了界面就直接移除
                if pipeSprite.position.x < -pipeSprite.size.width * 0.5 {
                    pipeSprite.removeFromParent()
                }
                
            }
        }
        
    }
    
    //小鸟开始飞
    func birdStartFly() {
        let flyAction = SKAction.animate(with: [
            SKTexture(imageNamed: "bird-1"),
            SKTexture(imageNamed: "bird-2"),
            SKTexture(imageNamed: "bird-3"),
            SKTexture(imageNamed: "bird-4")], timePerFrame: 0.25)
        bird.run(SKAction.repeatForever(flyAction), withKey: "fly")
    }
    
    //小鸟结束飞
    func birdStopFly() {
        bird.removeAction(forKey: "fly")
    }
    
    /*
     创建水管
     
     水管出现有什么特点
     
     1.成对的出现，一个在上一个在下，上下两个水管中间留有一定的高度的距离让小鸟能通过
     
     2.上下水管之间的高度距离是随机的，但是有个最小值和最大值
     
     3.一对水管出现之后向左移动，移动出了屏幕左侧就要把它移除掉
     
     4.一对水管出现之后，间隔一定的时间，再产生另一对水管，间隔的时间也是随机数，也要设一个最大和最三小值
     
     5.在游戏初始化状态下要停止重复创建水管，同时要移除掉场景里上一句残留的水管。在游戏进行中状态下才重复创建水管。在游戏结束状态下，停止创建水管，如果场景里还有存在水管，则停止左移
     */
    
    
    func startCreateRandomPipesAction() {
        //创建一个等待的action，等待时间是3.5秒，变化范围是1秒（指等待时间3.5秒前后1秒随机变）
        let waitAction = SKAction.wait(forDuration: 3.5, withRange: 1.0)
        
        //创建一个产生随机水管的action
        let generatePipeAction = SKAction.run {
            self.createRandomPipesAction()
        }
        
        //让场景开始重复执行 等待->创建->等待->创建......
        run(SKAction.repeatForever(SKAction.sequence([waitAction, generatePipeAction])), withKey: "createPipe")
    }
    
    func stopCreateRandomPipesAction() {
        self.removeAction(forKey: "createPipe")
    }
    
    /*
     创建随机管道
     
     创建随机数通常使用以下两个方法
     
     arc4random() -> UInt32
     
     这个方法会随机创建一个无符号Int32以内的整数
     
     arc4random_uniform(_ __upper_bound: UInt32) -> UInt32
     
     这个方法比上面那个方法多一个参数，这个参数就是设置这个能产生随机数的最大值，也就是限定了一个范围
     */
    func createRandomPipesAction() {
        //得到地板顶部到屏幕顶部的高度
        let height = self.size.height - self.floor1.size.height
        
        //上下管道之间的高度（最小高度是小鸟3.5倍，最大高度是小鸟5.5倍）
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height * 2))) + bird.size.height * 3.5
        
        //管道宽度
        let pipeWidth = CGFloat(60.0)
        
        //上管道高度（随机数，最大是height - pipeGap）
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height - pipeGap)))
        
        //下管道高度（height - 管道之间高度 - 上管道高度）
        let bottomPipeHeight = height - pipeGap - topPipeHeight
        
        //添加管道到场景
        addPipes(topSize: CGSize(width: pipeWidth, height: topPipeHeight), bottomSize: CGSize(width: pipeWidth, height: bottomPipeHeight))
    }
    
    func addPipes(topSize: CGSize, bottomSize: CGSize) {
        //上面的水管
        
        //利用上水管图片创建一个上水管的纹理对象
        let topTexture = SKTexture(imageNamed: "PipeDown")
        
        //利用纹理对象和传入的上水管大小创建一个上水管对象
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        
        //设置上水管位置
        topPipe.position = CGPoint(x: self.size.width + topPipe.size.width * 0.5, y: self.size.height - topPipe.size.height * 0.5)
        
        //设置水管名字，用来之后删除
        topPipe.name = "pipe"
        
        //下面的水管
        let bottomTexture = SKTexture(imageNamed: "PipeUp")
        
        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
     
        bottomPipe.position = CGPoint(x: self.size.width + bottomPipe.size.width * 0.5, y: self.floor1.size.height + bottomPipe.size.height * 0.5)
        
        bottomPipe.name = "pipe"
        
        //添加水管物理体
        
        topPipe.physicsBody = SKPhysicsBody(texture: topTexture, size: topSize)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        bottomPipe.physicsBody = SKPhysicsBody(texture: bottomTexture, size: bottomSize)
        bottomPipe.physicsBody?.isDynamic = false //是否受重力影响
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        
        //添加到场景中
        addChild(topPipe)
        addChild(bottomPipe)
    }
    
    func removeAllPipesNode() {
        gameOverLabel.removeFromParent()
        //循环检查场景的子节点，当子节点的名字是pipe时，移除
        for pipe in self.children where pipe.name == "pipe" {
            pipe.removeFromParent()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    //检测物理体的碰撞
    /*
     didBegin()
     会在当前物理世界有两个物理体碰撞接触了则回调用，这两个碰撞了的物理体的信息都在contact这个参数里面，分别是bodyA和bodyB
     */
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStatus != .running {
            return
        }
        
        var bodyA: SKPhysicsBody
        
        var bodyB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        if bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory || bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory {
            gameOver()
        }
        
    }
}


