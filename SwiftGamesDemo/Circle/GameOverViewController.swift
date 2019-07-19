//
//  GameOverViewController.swift
//  CircleGame
//
//  Created by 刘岑颖 on 2019/6/20.
//  Copyright © 2019 lcy. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    
    let screenRect = UIScreen.main.bounds
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let buttonWidth = CGFloat(120)
    
    var roundNumber: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        self.view.addSubview(showLabel)
        self.view.addSubview(startButtonBackView)
        self.view.addSubview(startButton)
        showLabel.text = "当前：ROUND\(roundNumber! - 1)"

        if (UserDefaults.standard.object(forKey: "BestRoundNumber") != nil) {
            let historyNumber = UserDefaults.standard.integer(forKey: "BestRoundNumber")
            if roundNumber! > historyNumber {
                UserDefaults.standard.set(self.roundNumber, forKey: "BestRoundNumber")
            }
            showLabel.text = "当前：ROUND\(roundNumber! - 1)\n最好：ROUND\(UserDefaults.standard.integer(forKey: "BestRoundNumber"))"

        } else {
            UserDefaults.standard.set(self.roundNumber, forKey: "BestRoundNumber")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startButtonAnimation()
    }

    func startButtonAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.startButtonBackView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            
        }
    }
    
    @objc func startGameAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - lazy loading
    private lazy var startButton: UIButton = {
        let button = UIButton(frame: CGRect(x:screenWidth / 2.0 - buttonWidth / 2.0,y:screenHeight / 2.0 - buttonWidth / 2.0 - 80, width:buttonWidth, height:buttonWidth))
        button.backgroundColor = UIColor.clear
        button.setTitle("RETRY", for: UIControl.State.normal)
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
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()

}
