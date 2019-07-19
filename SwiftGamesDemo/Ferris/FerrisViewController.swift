//
//  FerrisViewController.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/24.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class FerrisViewController: BaseViewController {
    
    let progressHeight: CGFloat = 1.5 * ScreenWidth / 5.0 + 20
    
    var flagBlue: Bool! {
        didSet {
            self.blueState.isHidden = !flagBlue
            self.pinkState.isHidden = flagBlue
        }
    }  //是否轮到蓝方
    
    var pinkScore: Int! = 0
    
    var blueScore: Int! = 0
    
    var arrowStrokePath: UIBezierPath!
    
    //保存所有红蓝方的endPoint
    var strokePoints = [NSValue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrowStrokePath = UIBezierPath()
        
        //随机数
        self.flagBlue = (arc4random() % 2 == 1) ? true : false

        //UI
        self.view.addSubview(pinkView)          //背景图
        self.view.addSubview(blueView)
        
        self.view.addSubview(backButton)        //返回按钮
        
        self.view.addSubview(pinkScoreLabel)    //分数
        self.view.addSubview(blueScoreLabel)
        
        self.view.addSubview(oddPinkRoundLabel) //黑色圆点
        self.view.addSubview(oddBlueRoundLabel)
        
        self.view.addSubview(pinkState)         //飞机
        self.view.addSubview(blueState)
        
        self.view.addSubview(pinkProgressView)  //红方的假针
        self.view.addSubview(blueProgressView)  //蓝方的假针
        
        self.view.addSubview(scoreLabel)        //比分
        self.updateScore()
        
        self.view.layer.addSublayer(self.centralAxisLayer)  //添加layer
        self.centralAxisLayer.add(rotation, forKey: "rotation")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - methods ----
    @objc func pinkClick() {
        if self.flagBlue == true {
            return
        }
        self.flagBlue = true
        
        UIView.animate(withDuration: 0.1, animations: {
            self.pinkProgressView.frame = CGRect(x: self.oddBlueRoundLabel.frame.origin.x, y: self.scoreLabel.center.y, width: 20, height: self.progressHeight)
            self.pinkProgressView.isHidden = false
        }) { (finished) in
            if finished {
                self.pinkProgressView.isHidden = true
                self.pinkProgressView.frame = CGRect(x: self.oddPinkRoundLabel.frame.origin.x, y: self.oddPinkRoundLabel.center.y - self.progressHeight + 10, width: 20, height: self.progressHeight)
                
                let bezierPath = UIBezierPath()
                /*
                 根据centralAxisLayer的坐标系
                 */
                
                let beginPoint = self.centralAxisLayer.convertPointWhenRotatingWithBenchmarkPoint(point: CGPoint(x: ScreenWidth / 10.0, y: ScreenWidth / 5.0), radius: ScreenWidth / 10.0)
                let endPoint = self.centralAxisLayer.convertPointWhenRotatingWithBenchmarkPoint(point: CGPoint(x: ScreenWidth / 10.0, y: ScreenWidth / 10.0 + ScreenWidth / 2.5 + 10), radius: ScreenWidth / 2.5 + 10)
                bezierPath.move(to: beginPoint)
                bezierPath.addLine(to: endPoint)
                bezierPath.move(to: endPoint)
                bezierPath.addArc(withCenter: endPoint, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
                self.arrowStrokePath.append(bezierPath)
                
                self.centralAxisLayer.path = self.arrowStrokePath.cgPath
                
                if self.isCrash(endPoint: endPoint) {
                    //发生碰撞，结束游戏
                    self.blueScore += 1
                    self.updateScore()
                    self.centralAxisLayer.pauseAnimation()
                    self.showBoomAlert()
                }
            }
        }
    }
    
    @objc func blueClick() {
        if self.flagBlue == false {
            return
        }
        self.flagBlue = false
        UIView.animate(withDuration: 0.1, animations: {
            self.blueProgressView.frame = CGRect(x: self.oddBlueRoundLabel.frame.origin.x, y: self.scoreLabel.center.y - self.progressHeight, width: 20, height: self.progressHeight)
            self.blueProgressView.isHidden = false
        }) { (finished) in
            if finished {
                self.blueProgressView.isHidden = true
                self.blueProgressView.frame = CGRect(x: self.oddBlueRoundLabel.frame.origin.x, y: self.oddBlueRoundLabel.frame.origin.y, width: 20, height: self.progressHeight)
                
                let bezierPath = UIBezierPath()
                /*
                 根据centralAxisLayer的坐标系
                 */
                
                let beginPoint = self.centralAxisLayer.convertPointWhenRotatingWithBenchmarkPoint2(point2: CGPoint(x: ScreenWidth / 10.0, y: ScreenWidth / 5.0), radius2: ScreenWidth / 10.0)
                let endPoint = self.centralAxisLayer.convertPointWhenRotatingWithBenchmarkPoint2(point2: CGPoint(x: ScreenWidth / 10.0, y: ScreenWidth / 10.0 + ScreenWidth / 2.5 + 10), radius2: ScreenWidth / 2.5 + 10)
                bezierPath.move(to: beginPoint)
                bezierPath.addLine(to: endPoint)
                bezierPath.move(to: endPoint)
                bezierPath.addArc(withCenter: endPoint, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
                self.arrowStrokePath.append(bezierPath)
                
                self.centralAxisLayer.path = self.arrowStrokePath.cgPath
                
                if self.isCrash(endPoint: endPoint) {
                    //发生碰撞，结束游戏
                    self.pinkScore += 1
                    self.updateScore()
                    self.centralAxisLayer.pauseAnimation()
                    self.showBoomAlert()
                }
            }
        }
    }
    
    //检测是否发生碰撞
    func isCrash(endPoint: CGPoint) -> Bool {
        for tmp in self.strokePoints {
            let tmpPoint = tmp.cgPointValue
            let dis = sqrt(pow(endPoint.x - tmpPoint.x, 2) + pow(endPoint.y - tmpPoint.y, 2))
            if(dis <= 20){
                return true
            }
        }
        self.strokePoints.append(NSValue.init(cgPoint: endPoint))
        return false
    }

    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateScore() {
        self.scoreLabel.attributedText = NSAttributedString.createScoreString(score1: self.pinkScore, score2: self.blueScore)
        self.pinkScoreLabel.text = String(format: "%d", self.pinkScore)
        self.blueScoreLabel.text = String(format: "%d", self.blueScore)
    }
    
    func showBoomAlert() {
        let alertCon = UIAlertController.init(title: "Boom！", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "继续", style: .cancel) { (action) in
            self.strokePoints.removeAll()
            self.centralAxisLayer.resumeAnimation()
            self.flagBlue = (arc4random() % 2 == 1) ? true : false
            //新开局，创建新的路径
            self.arrowStrokePath = UIBezierPath()
            self.centralAxisLayer.path = self.arrowStrokePath.cgPath
        }
        alertCon.addAction(cancel)
        self.present(alertCon, animated: true, completion: nil)
    }

    // MARK: - lazy loading ----
    
    // blue -----------------------
    
    lazy var blueView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight / 2.0))
        view.backgroundColor = blueColor
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(blueClick))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var blueScoreLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: ScreenWidth - 50, y: 50, width: 50, height: 20))
        label.textAlignment = .center
        label.textColor = .black
        label.text = "0"
        return label
    }()
    
    lazy var oddBlueRoundLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: self.view.center.x - 10, y: 120, width: 20, height: 20))
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.backgroundColor = .black
        return label
    }()
    
    lazy var blueState: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "flagBlue"))
        imageView.frame = CGRect(x: self.view.center.x - 18.5, y: 80, width: 37, height: 24)
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        return imageView
    }()
    
    lazy var blueProgressView: UIView = {
        let progressView = UIView.init(frame: CGRect(x: self.oddBlueRoundLabel.frame.origin.x, y: self.oddBlueRoundLabel.center.y, width: 20, height: progressHeight))
        progressView.backgroundColor = UIColor.clear
        progressView.isHidden = true
        let lineView = UIView.init(frame: CGRect(x: 9, y: 0, width: 2, height: 1.5 * ScreenWidth / 5.0))
        lineView.backgroundColor = .black
        progressView.addSubview(lineView)

        return progressView
    }()
    
    // pink -----------------------
    lazy var pinkView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: ScreenHeight / 2.0, width: ScreenWidth, height: ScreenHeight / 2.0))
        view.backgroundColor = pinColor
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(pinkClick))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var pinkScoreLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: ScreenHeight - 50, width: 50, height: 20))
        label.textAlignment = .center
        label.textColor = .black
        label.text = "0"
        return label
    }()
    
    lazy var oddPinkRoundLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: self.view.center.x - 10, y: ScreenHeight - 140, width: 20, height: 20))
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.backgroundColor = .black
        return label
    }()
    
    lazy var pinkState: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "flagRed"))
        imageView.frame = CGRect(x: self.view.center.x - 18.5, y: ScreenHeight - 80, width: 37, height: 24)
        return imageView
    }()
    
    lazy var pinkProgressView: UIView = {
        let progressView = UIView.init(frame: CGRect(x: self.oddPinkRoundLabel.frame.origin.x, y: self.oddPinkRoundLabel.center.y - progressHeight + 10, width: 20, height: progressHeight))
        progressView.backgroundColor = UIColor.clear
        progressView.isHidden = true
        let lineView = UIView.init(frame: CGRect(x: 9, y: 0, width: 2, height: 1.5 * ScreenWidth / 5.0))
        lineView.backgroundColor = .black
        progressView.addSubview(lineView)
        
        return progressView
    }()

    
    // others -----------------------
    lazy var backButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: ScreenHeight * 0.5 - 15, width: 60, height: 30))
        button.setTitle("Back", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    //屏幕中间的比分label
    lazy var scoreLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth / 5.0, height: ScreenWidth / 5.0))
        label.center = self.view.center
        label.backgroundColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.layer.cornerRadius = ScreenWidth / 10.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var centralAxisLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.path = self.arrowStrokePath.cgPath
        shapeLayer.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth / 5.0, height: ScreenWidth / 5.0)
        shapeLayer.position = self.view.center
        return shapeLayer
    }()
    
    lazy var rotation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation.init(keyPath: "transform.rotation.z")
        animation.values = [0.0, (2.0 * Double.pi)]
        animation.duration = 7
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()
}

