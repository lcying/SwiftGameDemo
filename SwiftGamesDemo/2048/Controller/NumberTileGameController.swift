//
//  NumberTileGameController.swift
//  swift_2048
//
//  Created by 刘岑颖 on 2018/5/28.
//  Copyright © 2018年 lcy. All rights reserved.
//

import UIKit

class NumberTileGameController: UIViewController {
    
    // 游戏开始的行数
    var dimension: Int
    
    // 游戏胜利时最大方格上的数字
    var threshold: Int
    
    //游戏板块
    var board: GameBoardView?
    
    //数据模型
    var model: GameModel?
    
    //显示分数的视图
    var scoreView: ScoreViewProtocol?
    
    //游戏板宽
    let boardWidth: CGFloat = 300
    
    //scoreView和gameBoard之间的距离
    var viewPadding: CGFloat = 10.0
    
    //方格之间的间距，有大小间距之分，当四行以上就是小间距
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    
    //y轴上的偏移量
    let verticalViewOffset: CGFloat = 0.0
    
    //初始化 d = 4 , t = 2048
    init(dimension d: Int, threshold t: Int) {
        dimension = d > 2 ? d : 2 //最小2
        threshold = t > 8 ? t : 8 //最小8
        super.init(nibName: nil, bundle: nil)
        
        //初始化数据模型
        model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        
        view.backgroundColor = .white
        
        //设置上下左右的手势
        setupSwipeControls()
    }
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 80, width: 100, height: 40))
        button.backgroundColor = .red
        button.setTitle("reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 80, width: 100, height: 40))
        button.backgroundColor = .red
        button.setTitle("back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        view.addSubview(resetButton)
        view.addSubview(backButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Methods ---------------------

extension NumberTileGameController {
    
    @objc func reset() {
        assert(board != nil && model != nil)
        let b = board!
        let m = model!
        b.reset()
        m.reset()
        m.insertTileAtRandomLocation(withValue: 2)
        m.insertTileAtRandomLocation(withValue: 2)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupGame() {
        let vcHeight = self.view.bounds.size.height
        let vcWidth = self.view.bounds.size.width
        
        //一个view在当前界面上居中时的左右边距
        func xPositionToCenterView(_ v: UIView) -> CGFloat {
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5 * (vcWidth - viewWidth)
            return tentativeX >= 0 ? tentativeX : 0
        }
        
        //得到views里面第order个view的y轴值
        func yPositionFromViewAtPosition(_ order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            
            /*
             views.map({ $0.bounds.size.height }) 得到的是一个内容为views里面子view的height的数组
             
             array.reduce(a, {$0 + $1})表示 ：a + array数组中所有元素的和
             */
            
            //分数栏 + 游戏板 + 之间高度
            let totalHeight = CGFloat(views.count - 1) * viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
            
            //分数栏距离上边边距
            let viewsTop = 0.5 * (vcHeight - totalHeight) >= 0 ? 0.5 * (vcHeight - totalHeight) : 0
            
            var acc: CGFloat = 0
            for i in 0 ..< order {
                acc += viewPadding + views[i].bounds.size.height
            }
            
            return viewsTop + acc
        }
        
        //创建显示分数的view
        let scoreView = ScoreView(backgroundColor: .black,  textColor: .white, font: UIFont(name: "HelveticaNeue", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0), radius: 6)
        scoreView.score = 0
        
        //创建游戏板
        let padding : CGFloat = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding * (CGFloat(dimension - 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1))) / CGFloat(dimension) //一个方格的宽度
        let gameboard = GameBoardView(
            dimension: dimension,
            tileWidth: width,
            tilePadding: padding,
            cornerRadius: 6,
            backgroundColor: .black,
            foregroundColor: .darkGray)
        
        let views = [scoreView, gameboard]
        
        var f = scoreView.frame
        f.origin.x = xPositionToCenterView(scoreView)
        f.origin.y = yPositionFromViewAtPosition(0, views: views)
        scoreView.frame = f
        
        f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionFromViewAtPosition(1, views: views)
        gameboard.frame = f
        
        view.addSubview(gameboard)
        self.board = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
        
        assert(model != nil)
        let m = model!
        //初始化的时候随机插入两个数值为2的方格
        m.insertTileAtRandomLocation(withValue: 2)
        m.insertTileAtRandomLocation(withValue: 2)
        
    }
    
    //给界面添加上下左右的手势
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameController.upCommand(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameController.downCommand(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameController.leftCommand(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameController.rightCommand(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc(up:)
    func upCommand(_ r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.up) { (changed: Bool) in
            //移动结束后的block
            if changed {
                self.followUp()
            }
        }
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.down) { (changed: Bool) in
            if changed {
                self.followUp()
            }
        }
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.left) { (changed: Bool) in
            if changed {
                self.followUp()
            }
        }
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer) {
        assert(model != nil)
        let m = model!
        m.queueMove(direction: MoveDirection.right) { (changed: Bool) in
            if changed {
                self.followUp()
            }
        }
    }
    
    func followUp() {
        assert(model != nil)
        let m = model!
        let (userWon, _) = m.userHasWon()
        
        //如果赢了
        if userWon {
            let alertVC = UIAlertController(title: "Victory", message: "You won!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            let resetAction = UIAlertAction(title: "reset", style: .default, handler: { action in
                self.reset()
            })

            alertVC.addAction(cancelAction)
            alertVC.addAction(resetAction)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        //随机插入 插入4/2
//        let randomVal = Int(arc4random_uniform(10))
//        m.insertTileAtRandomLocation(withValue: randomVal == 1 ? 4 : 2)

        //只插入2
        m.insertTileAtRandomLocation(withValue: 2)

        //失败
        if m.userHasLost() {
            let alertVC = UIAlertController(title: "Defeat", message: "You lost.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            let resetAction = UIAlertAction(title: "reset", style: .default, handler: { action in
                self.reset()
            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(resetAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

// MARK: - GameModelProtocol ---------------------

extension NumberTileGameController: GameModelProtocol {
    func scoreChanged(to score: Int) {
        if scoreView == nil {
            return
        }
        let s = scoreView!
        s.scoreChanged(to: score)
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveOneTile(from: from, to: to, value: value)
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveTwoTiles(from: from, to: to, value: value)
    }
    
    func insertTile(at location: (Int, Int), withValue value: Int) {
        assert(board != nil)
        let b = board!
        b.insertTile(at: location, value: value)
    }
    
}
