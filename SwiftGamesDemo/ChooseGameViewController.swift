//
//  ChooseGameViewController.swift
//  DoubleGames
//
//  Created by 刘岑颖 on 2019/6/21.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class ChooseGameViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(backImageView)
        self.view.addSubview(buttonBackView)
        self.buttonBackView.addSubview(gameButton0)
        self.buttonBackView.addSubview(gameButton1)
        self.buttonBackView.addSubview(gameButton2)
        self.buttonBackView.addSubview(gameButton3)
        self.buttonBackView.addSubview(gameButton4)

        self.view.addSubview(backButton)
    }
    
    @objc func button0Action() {
        self.navigationController?.pushViewController(NumberTileGameController(dimension: 4, threshold: 2048), animated: true)
    }
    
    @objc func button1Action() {
        self.navigationController?.pushViewController(FerrisViewController(), animated: true)
    }
    
    @objc func button2Action() {
        self.navigationController?.pushViewController(StartCircleViewController(), animated: true)
    }
    
    @objc func button3Action() {
        self.navigationController?.pushViewController(Game24ViewController(), animated: true)
    }
    
    @objc func button4Action() {
        self.navigationController?.pushViewController(GameViewController(), animated: true)
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - lazy loading ----
    
    lazy var backImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "bg.jpeg"))
        imageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        return imageView
    }()
    
    lazy var buttonBackView: UIView = {
        let view = UIView.init(frame: CGRect(x: (ScreenWidth - 250) * 0.5, y: 80, width: 250, height: 355))
        view.backgroundColor = pinColor
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var gameButton0: UIButton = {
        let button = normalButton(frame: CGRect(x: 10, y: 10, width: 230, height: 55), backColor: blueColor, title: "2048")
        button.addTarget(self, action: #selector(button0Action), for:.touchUpInside)
        return button
    }()
    
    lazy var gameButton1: UIButton = {
        let button = normalButton(frame: CGRect(x: 10, y: 75, width: 230, height: 55), backColor: blueColor, title: "见缝插针")
        button.addTarget(self, action: #selector(button1Action), for:.touchUpInside)
        return button
    }()
    
    lazy var gameButton2: UIButton = {
        let button = normalButton(frame: CGRect(x: 10, y: 140, width: 230, height: 55), backColor: blueColor, title: "circle")
        button.addTarget(self, action: #selector(button2Action), for:.touchUpInside)
        return button
    }()
    
    lazy var gameButton3: UIButton = {
        let button = normalButton(frame: CGRect(x: 10, y: 215, width: 230, height: 55), backColor: blueColor, title: "24点")
        button.addTarget(self, action: #selector(button3Action), for:.touchUpInside)
        return button
    }()

    lazy var gameButton4: UIButton = {
        let button = normalButton(frame: CGRect(x: 10, y: 290, width: 230, height: 55), backColor: blueColor, title: "小鸟")
        button.addTarget(self, action: #selector(button4Action), for:.touchUpInside)
        return button
    }()

    lazy var backButton: UIButton = {
        let button = normalButton(frame: CGRect(x: (ScreenWidth - 230) * 0.5, y: self.buttonBackView.bottom + 30, width: 230, height: 55), backColor: pinColor, title: "Back")
        button.addTarget(self, action: #selector(backAction), for:.touchUpInside)
        return button
    }()
    
    func normalButton(frame: CGRect, backColor: UIColor, title: String) -> UIButton {
        let button = UIButton.init()
        button.frame = frame
        button.backgroundColor = backColor
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return button
    }
}
