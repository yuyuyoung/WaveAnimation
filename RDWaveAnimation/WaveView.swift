//
//  WaveView.swift
//  RDWaveAnimation
//
//  Created by yangyu on 2019/2/23.
//  Copyright © 2019 YangYiYu. All rights reserved.
//

import UIKit

enum RNWavePathType {
    case sin
    case cos
}

class WaveView: UIView {
    
    let font: CGFloat = 100
    
    var waveColor = #colorLiteral(red: 0.2352941176, green: 0.5647058824, blue: 0.862745098, alpha: 1) //破浪颜色
    var word: String?
    var showWord: String {
        get {
            guard let w = word else {
                return "RD"
            }
            return String(w.prefix(2))
        }
    }
    
    var waveDisplaylink : CADisplayLink?
    var type: RNWavePathType = .sin
    
    var maxAmplitude : Float = 0.0 // 振幅
    var waveCycle : Float = 0.0 // 周期
    var waveSpeed : Float = 0.0 // 速度
    var offsetX : Float = 0.0 // 波浪 x 位移
    var currentWavePointY : Float = 0.0 // 高度Y
    var waterWaveWidth : Int = 0 // 宽度
    //Lazy var
    lazy var waveLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = waveColor.cgColor
        layer.path = self.getWavePath()
        return layer
    }()
    
    lazy var waveMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = waveColor.cgColor
        layer.path = self.getWavePath()
        return layer
    }()
    
    lazy var cycleMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        layer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.height / 2).cgPath
        return layer
    }()
    
    lazy var cycleLayer: CALayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = waveColor.cgColor
        layer.lineWidth = 0.3
        layer.path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)  , radius: self.bounds.width / 2 + 0.3, startAngle: 0, endAngle: 360, clockwise: true).cgPath
        return layer
    }()
    
    lazy var backWordLabel: UILabel = {
        let label = UILabel()
        label.frame = self.bounds
        label.font = UIFont.boldSystemFont(ofSize: font)
        label.textColor = waveColor
        label.textAlignment = .center
        label.text = self.showWord
        return label
    }()
    
    lazy var frontWordLabel: UILabel = {
        let label = UILabel()
        label.frame = self.bounds
        label.font = UIFont.boldSystemFont(ofSize: font)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = self.showWord
        return label
    }()
    
    init(_ frame: CGRect, word: String?) {
        self.word = word;
        super.init(frame: frame)
        self.setUpData()
        self.setUpInterface()
    }
    
    init(_ frame: CGRect, word: String?, waveColor: UIColor) {
        self.word = word;
        super.init(frame: frame)
        self.waveColor = waveColor
        self.setUpData()
        self.setUpInterface()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpData()
        self.setUpInterface()
    }
    
    override init(frame: CGRect) {
        self.word = nil
        super.init(frame: frame)
        self.setUpData()
        self.setUpInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpData()
        self.setUpInterface()
    }
    
    private func setUpData() {
        
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //设置波浪属性值
        self.maxAmplitude = 12
        self.waveCycle =  Float(2 * CGFloat(Double.pi) / self.frame.size.width)
        self.waterWaveWidth = Int(UIScreen.main.bounds.size.width + 10)
        self.waveSpeed = Float(0.2 / Double.pi)
        self.currentWavePointY = Float(self.bounds.height / 2)
        self.offsetX = 0
    }
    
    private func setUpInterface() {
        
        self.layer.addSublayer(self.cycleLayer)
        self.addSubview(self.backWordLabel)
        self.layer.addSublayer(self.waveLayer)
        self.addSubview(self.frontWordLabel)
        self.frontWordLabel.layer.mask = self.waveMaskLayer
        self.waveLayer.mask = self.cycleMaskLayer
        
        self.startAnimation()
    }
    
    deinit {
        waveDisplaylink!.invalidate()
        waveDisplaylink = nil
        cycleMaskLayer.removeFromSuperlayer()
        waveLayer.removeFromSuperlayer()
    }
}

//MARK: Wave Animation

extension WaveView {
    
    @objc func startAnimation() {
        
        if self.waveDisplaylink == nil {
            waveDisplaylink = CADisplayLink(target: self, selector: #selector(getCurrentWave(displayLink:)))
            waveDisplaylink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }else {
            waveDisplaylink!.isPaused = false
        }
    }
    
    @objc func stopAnimation() {
        
        guard let displaylink = waveDisplaylink else {
            return
        }
        
        displaylink.isPaused = true
    }
    
    @objc private func getCurrentWave(displayLink: CADisplayLink) {
        
        offsetX += waveSpeed
        self.waveLayer.path = self.getWavePath()
        self.waveMaskLayer.path = self.getWavePath()
    }
    
    func getWavePath() -> CGPath {
        
        let wavePath = UIBezierPath()
        var y: Float = currentWavePointY
        
        for x in 0...self.waterWaveWidth {
            if self.type == .sin {
                y = maxAmplitude * sin(waveCycle * Float(x) + offsetX) + currentWavePointY
            }else {
                y = maxAmplitude * cos(waveCycle * Float(x) + offsetX) + currentWavePointY
            }
            if x == 0 {
                wavePath.move(to: CGPoint(x: CGFloat(0), y: CGFloat(y)))
            }else {
                wavePath.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        
        wavePath.addLine(to: CGPoint(x: CGFloat(waterWaveWidth), y: self.frame.size.height))
        wavePath.addLine(to: CGPoint(x: CGFloat(0), y: self.frame.size.height))
        
        return wavePath.cgPath
    }
}
