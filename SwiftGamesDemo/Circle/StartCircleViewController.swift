//
//  StartCircleViewController.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/19.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class StartCircleViewController: UIViewController {

    let screenRect = UIScreen.main.bounds
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let buttonWidth = CGFloat(120)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        for _ in 0...7 {
            startBackRandomCircleAnimation()
        }
        self.view.addSubview(startButtonBackView)
        self.view.addSubview(startButton)
        startButtonAnimation()        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func startButtonAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.startButtonBackView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            
        }
    }
    
    func startBackRandomCircleAnimation() {
        let circle = Circle.randomCircle()
        let circleView = CircleView.init(circle: circle)
        circleView.alpha = 0.0;
        circleView.isUserInteractionEnabled = false
        self.view.addSubview(circleView)
        self.view.sendSubviewToBack(circleView)
        circleView.tag = 100;
        let delay = Double(arc4random()) / Double(UINT32_MAX) * 1.5
        let duration = Double(arc4random()) / Double(UINT32_MAX) * 3 + 0.5

        weak var weakSelf = self
        UIView.animate(withDuration:duration, delay: delay, options: [.curveLinear], animations: {
            circleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            circleView.alpha = 0.4
        }) { (finished) in
            UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                circleView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                circleView.alpha = 0.0
            }, completion: { (finished) in
                circleView.removeFromSuperview()
                if finished {
                    weakSelf?.startBackRandomCircleAnimation()
                }
            })
        }
    }

    @objc func startGameAction() {
        self.startButton.isHidden = true
        
        self.startButtonBackView.transform = CGAffineTransform.identity
        weak var weakSelf = self
        UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear], animations: {
            weakSelf!.startButtonBackView.transform = CGAffineTransform(scaleX: 20, y: 20)
        }) { (finished) in
            
            weakSelf!.view.addSubview(weakSelf!.showLabel)
            weakSelf?.showLabel.alpha = 0
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveLinear], animations: {
                weakSelf?.showLabel.alpha = 1
            }, completion: { (finished) in
                weakSelf!.present(CircleViewController(), animated: false, completion: nil)
            })
        }
    }
    
    // MARK: - lazy loading
    private lazy var startButton: UIButton = {
        let button = UIButton(frame: CGRect(x:screenWidth / 2.0 - buttonWidth / 2.0,y:screenHeight / 2.0 - buttonWidth / 2.0 - 80, width:buttonWidth, height:buttonWidth))
        button.backgroundColor = UIColor.clear
        button.setTitle("START", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.bold)
        button.addTarget(self, action: #selector(startGameAction), for: .touchUpInside)
        return button
    }()
    
    lazy var startButtonBackView: UIView = {
        let view = UIView(frame: CGRect(x:screenWidth / 2.0 - buttonWidth / 2.0,y:screenHeight / 2.0 - buttonWidth / 2.0 - 80, width:buttonWidth, height:buttonWidth))
        view.backgroundColor = ColorUtils.randomColor()
        view.layer.cornerRadius = buttonWidth / 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var showLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textColor = UIColor.white
        label.text = "ROUND\n1"
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()
}

