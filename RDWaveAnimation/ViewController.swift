//
//  ViewController.swift
//  RDWaveAnimation
//
//  Created by yangyu on 2019/2/23.
//  Copyright © 2019 YangYiYu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let waveView = WaveView(CGRect(x: self.view.bounds.width / 2 - 80, y: self.view.bounds.height / 2 - 80, width: 160, height: 160), word: "YY")
        self.view.addSubview(waveView)
        
    }
}

