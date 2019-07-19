//
//  Game24ViewController.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/21.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class Game24ViewController: BaseViewController {
    
    var argsCopy: [[String]]!
    
    var score1: Int = 0 //蓝方
    var score2: Int = 0 //红方
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(playView1)
        self.view.addSubview(playView2)
        self.view.addSubview(backButton)
        self.view.addSubview(passButton)
        self.view.addSubview(resultView1)
        self.view.addSubview(resultView2)
        
        weak var weakeSelf = self
        self.playView1.block = {
            weakeSelf?.score1 += 1
            let scoreString = "Score: \(weakeSelf!.score1) : \(weakeSelf!.score2)"
            var titleString = "Correct!"
            if weakeSelf?.score2 == 3 {
                titleString = "You won!"
            }
            weakeSelf?.resultView1.show(score: scoreString, title: titleString)
        }
        
        self.playView2.block = {
            weakeSelf?.score2 += 1
            let scoreString = "Score: \(weakeSelf!.score2) : \(weakeSelf!.score1)"
            var titleString = "Correct!"
            if weakeSelf?.score2 == 3 {
                titleString = "You won!"
            }
            weakeSelf?.resultView2.show(score: scoreString, title: titleString)
        }
        
        self.resultView1.block = {
            if weakeSelf?.score1 == 3 {
                //新开一轮
                weakeSelf?.startGame()
            } else {
                //继续
                weakeSelf?.passAction()
            }
        }
        
        self.resultView2.block = {
            if weakeSelf?.score2 == 3 {
                //新开一轮
                weakeSelf?.startGame()
            } else {
                //继续
                weakeSelf?.passAction()
            }
        }
        
        startGame()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - methods -----
    
    func getQuestion(isPass: Bool) -> Question {
        let question = Question()
        let index = (Int)(arc4random()) % self.argsCopy.count
        let array = self.argsCopy[index]
        question.number0 = array[0]
        question.number1 = array[1]
        question.number2 = array[2]
        question.number3 = array[3]
        if isPass == false {
            self.argsCopy.remove(at: index)
        }
        return question
    }
    
    func startGame() {
        argsCopy = args
        playView1.reset()
        playView2.reset()
        if argsCopy.count > 0 {
            let question = getQuestion(isPass: false)
            playView1.question = question
            playView2.question = question
        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func passAction() {
        playView1.reset()
        playView2.reset()
        if argsCopy.count > 0 {
            let question = getQuestion(isPass: true)
            playView1.question = question
            playView2.question = question
        }
    }
    
    // MARK: - lazy loading ----
    lazy var playView1: PlayView = {
        let view = Bundle.main.loadNibNamed("PlayView", owner: nil, options: nil)?.last as! PlayView
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight * 0.5)
        view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        let theme = Theme()
        theme.borderColor = pinColor
        theme.backColor = blueColor
        view.theme = theme
        return view
    }()

    lazy var playView2: PlayView = {
        let view = Bundle.main.loadNibNamed("PlayView", owner: nil, options: nil)?.last as! PlayView
        view.frame = CGRect(x: 0, y: ScreenHeight * 0.5, width: ScreenWidth, height: ScreenHeight * 0.5)
        let theme = Theme()
        theme.borderColor = blueColor
        theme.backColor = pinColor
        view.theme = theme
        return view
    }()
    
    lazy var passButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: ScreenWidth - 60, y: ScreenHeight * 0.5 - 15, width: 60, height: 30))
        button.setTitle("Pass", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(passAction), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: ScreenHeight * 0.5 - 15, width: 60, height: 30))
        button.setTitle("Back", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    lazy var resultView1: ResultView = {
        let view = ResultView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        view.color = blueColor
        view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        view.isHidden = true
        return view
    }()
    
    lazy var resultView2: ResultView = {
        let view = ResultView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        view.color = pinColor
        view.isHidden = true
        return view
    }()
}
