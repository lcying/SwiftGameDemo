//
//  CircleViewController.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

/*
 CircleViewController 在加载的时候遍历 CircleFactory 的 Circle 数组，生成相对应的 CircleView，并加入到 view hierarchy 中。
 同时，CircleViewController 有一个保存 CircleView 的数组 circleViews，这个数组的用处主要是给所有的 circle view 添加交互的动画。
 CircleViewController 还有一个 lastCircleView 用来保存最后一个 circle view。
 
 这里的代码有一个 Swift 相较于 Objective-C 的新操作符 ===，它比较的就是两个对象的引用是否相等，其相反的操作符是 !==。
 */

class CircleViewController: UIViewController {

    var circleViewArray = [CircleView]()
    
    var lastCircleView: CircleView?
    
    var touched: Bool = true
    
    let tolerance: CGFloat = 5
    
    var roundNumber: Int = 1
    
    //倒计时五秒之内点不出来就失败
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCircleView()
        showCircleViewAnimation()
        self.view.addSubview(loadingView)
        loadingView.frame = CGRect(x: 0, y: 0, width: 3, height: ScreenUtils.screenHeight)

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressAction), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate() // 计时器销毁
    }
    
    /*
     判断是否正确点击了最新的圆，就是在 func touchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) 判断点击是否在 lastCircleView 中，同时也需要做一定的容错，毕竟手指不是鼠标。
     这里为了防止多次点击，用了一个 bool 变量 touched 来判断是否已经点击过。
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touched {
            touched = false

            let touch = touches.first!
            let point = touch.location(in: self.view)
            
            let sizeSide = CGFloat(CircleFactory.sharedCircleFactory.circles.last!.radius) + tolerance
            
            var roundedRect = lastCircleView!.frame
            roundedRect.origin.x -= tolerance
            roundedRect.origin.y -= tolerance
            roundedRect.size.width += 2*tolerance
            roundedRect.size.height += 2*tolerance
            
            let maskPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: sizeSide, height: sizeSide))
            if maskPath.contains(point) {
                //下一轮
                showNextRound()
                
                touched = true
            } else {
                //游戏结束
                showWarningAnimation()
            }
        }
    }
    
    // MARK: - methods ------------------------------
    
    func showCircleView() {
        //重置
        for cv in circleViewArray {
            cv.removeFromSuperview()
        }
        circleViewArray.removeAll()
        roundNumber = 1
        touched = true
        CircleFactory.sharedCircleFactory.circles.removeAll()
        
        //获取圆的模型
        CircleFactory.sharedCircleFactory.addCircle()
        //添加圆的view到界面上
        for circle in CircleFactory.sharedCircleFactory.circles {
            let circleView = CircleView.init(circle: circle)
            self.view.addSubview(circleView)
            circleViewArray.append(circleView)
        }
        lastCircleView = circleViewArray.last
    }
    
    func showCircleViewAnimation() {
        
        for cv in circleViewArray {
            cv.backgroundColor = ColorUtils.randomColor()
            
            let delay = Double(arc4random()) / Double(UINT32_MAX) * 0.3
            
            cv.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
                cv.transform = CGAffineTransform.identity
            }) { (finished) in
                print("finished = \(finished)")
            }
        }
        
    }
    
    func showWarningAnimation() {
        self.lastCircleView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
            self.lastCircleView?.transform = CGAffineTransform.identity
        }) { (finished) in
            if finished {
                let vc = GameOverViewController()
                vc.roundNumber = self.roundNumber
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func showNextRound() {
        roundNumber += 1
        self.showLabel.alpha = 1
        self.showLabel.text = "ROUND\n\(roundNumber)"
        self.lastCircleView?.transform = CGAffineTransform.identity
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 3, height: ScreenUtils.screenHeight)
        timer.fireDate = Date.distantPast//计时器继续
        
        weak var weakSelf = self
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveLinear], animations: {
            weakSelf!.lastCircleView?.transform = CGAffineTransform(scaleX: 60, y: 60)
        }) { (finished) in
            weakSelf!.view.addSubview(weakSelf!.showLabel)
            weakSelf?.showLabel.alpha = 0
            UIView.animate(withDuration: 0.6, delay: 0, options: [.curveLinear], animations: {
                weakSelf?.showLabel.alpha = 1
            }, completion: { (finished) in
                weakSelf!.showNextRoundViews()
            })
        }
    }
    
    func showNextRoundViews() {
        self.showLabel.alpha = 0
        CircleFactory.sharedCircleFactory.addCircle()
        let circleView = CircleView.init(circle: CircleFactory.sharedCircleFactory.circles.last!)
        self.view.addSubview(circleView)
        circleViewArray.append(circleView)
        lastCircleView = circleView
        //动画
        self.showCircleViewAnimation()
    }
    
    func showProgressAnimation() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            //延迟0.3秒执行
            
        }
    }
    
    @objc func updateProgressAction() {
        let oldHeight = self.loadingView.frame.size.height
        let partHeight = ScreenUtils.screenHeight / 70
        let y = ScreenUtils.screenHeight - (oldHeight - partHeight)
        if y >= ScreenUtils.screenHeight {
            self.timer.fireDate = Date.distantFuture//计时器暂停
            //游戏结束
            showWarningAnimation()
        }
        self.loadingView.frame = CGRect(x: 0, y: y, width: 3, height: oldHeight - partHeight)
    }

    // MARK: - lazy loading ------------------------------
    lazy var showLabel: UILabel = {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        label.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var loadingView: UIView = {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 3, height: screenHeight))
        view.backgroundColor = UIColor.red
        return view
    }()
    
}
