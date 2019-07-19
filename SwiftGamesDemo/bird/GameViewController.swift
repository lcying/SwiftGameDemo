//
//  GameViewController.swift
//  FlappyBird_lcy
//
//  Created by lcy on 2018/5/24.
//  Copyright © 2018year lcy. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = SKView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        
        if let view = self.view as! SKView? {
            
            
            //通过代码创建一个GameScene类的实例对象
            let scene = GameScene(size: self.view.bounds.size)
            
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
            
            /*
             
             每一个节点它都有一个zPosition属性,并且默认值都是0
             　　　　现在每一个节点它都是按照各个子节点的z-position绘制其子节点,并且是从低到高.
             　　　　我们添加了如下一行代码到GameViewController.Swift中:
             　　　　skView.ignoresSiblingOrder=true
             　　　　如果ignoesSiblingOrder被设置为true,SpriteKit就会将对于相同zPosition子节点的绘制顺序不会做任何的一个保证，这点是需要理解清楚。
             　　　　如果ignoresSiblingOrder被设置为false,SpriteKit将按照相同zPosition子节点添加到其父节点的顺序绘制它们.
             　　　　在一般情况下,将其设置为true是有利的,是因为它允许SpriteKit完成潜在的性能优化可以使游戏运行的更加快
             　　　　但需要注意的是，当设置该属性为true可能是一不小心就会引起一些问题.就比如：如果你添加一个僵尸到场景中,该僵尸的zPosition和背景的zPosition是相同的—都是0.SpriteKit可能在僵尸前面绘制背景,那么这将会是盖住僵尸的最终的显示效果.
             　　　　因此为了避免这种情况的出现,你将设置背景的zPosition为-1,这样SpriteKit将在任何默认zPosition为0的节点之前绘制背景，关于节点方面的更多的教程，我们将继续送上更多的实用的资讯，全面的来去帮助大家提升学习！游戏 开发是属于一个综合能力的体现，这就要求开发者要掌握一些基本的编程、节点、以及插件的实用技术。
             
             */
           
            view.ignoresSiblingOrder = true

            //展示界面右下角的nodes和fps信息
            view.showsFPS = true
            
            view.showsNodeCount = true
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
