//
//  VideoPlayerControl.swift
//  ijkswift
//
//  Created by 左权 on 2018/9/18.
//  Copyright © 2018年 YTTV. All rights reserved.
//

import UIKit
import IJKMediaFramework

class VideoPlayerControl: UIControl {


    lazy var topPanel = contorlModel.topPanel
    lazy var bottomPanel = contorlModel.bottomPanel
    lazy var overlayPanel = contorlModel.overlayPanel
    lazy var backBtn = contorlModel.backBtn
    lazy var titleLabel = contorlModel.titleLabel
    lazy var playBtn = contorlModel.playBtn
    lazy var pauseBtn = contorlModel.pauseBtn
    lazy var currentTimeLabel = contorlModel.currentTimeLabel
    lazy var totalDurationLabel = contorlModel.totalDurationLabel
    lazy var slider = contorlModel.slider
    lazy var fullScreenBtn = contorlModel.fullScreenBtn
    
    weak var delegatePlayer: IJKMediaPlayback?
    
    lazy var gestureControl = GestureControlModel()

    lazy var contorlModel = ControlModel()


    var isDragged = Bool()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contorlModel.layoutUI(view: self)
        contorlModel.initUI()
        addActtion()
        gestureControl.disablegesturetype = DisableGestureType.DisableGestureTypeUnknown
    }
    
    func addActtion() {
        playBtn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        pauseBtn.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchCancel), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUpInside), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenChange(sender:)), for: .touchUpInside)
    }
    
    func addGesture(view: VideoPlayerView?) {
        gestureControl.addGesToView(view: view)
        gestureControl.singleTaped = { [weak view] (gesModle) in
            view?.singleTaped()

        }
        gestureControl.beganPan = { [weak view] (gesModel,direction,location) in
            view?.beginPan(control: gesModel, direction: direction, location: location)
        }
        gestureControl.changedPan = { [weak view] (gesModle,direction,location,velocity) in
            view?.changePan(control: gesModle, direction: direction, location: location, velocity: velocity)
        }
        gestureControl.endPan = { [weak view] (gesModel,direction,location) in
            view?.endPan(control: gesModel, direction: direction, location: location)
        }
    }
    
    @objc func playAction() {
        delegatePlayer?.play()
        refreshVideoControl()
    }
    
    @objc func pauseAction() {
        delegatePlayer?.pause()
        refreshVideoControl()
    }
    
    @objc func fullScreenChange(sender:Button){
        if UIDevice.current.orientation == .portrait {
            let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
            UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }else{
            //强制归正：
            let oriention = UIInterfaceOrientation.portrait // 设置屏幕为竖屏
            UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    @objc func sliderTouchDown() {
        beginDrag()
    }
    
    @objc func sliderTouchCancel() {
        endDrag()
    }
    
    @objc func sliderValueChanged() {
        continueDrag()
    }
    
    @objc func sliderTouchUpInside() {
        delegatePlayer?.currentPlaybackTime = TimeInterval(slider.value)
        endDrag()
    }
    
    func showNoFade() {
        self.isHidden = false
        cancelDelayHide()
        refreshVideoControl()
    }
    
    func showAndFade() {
        showNoFade()
        self.perform(#selector(hide), with: nil, afterDelay: DELAY_TIME)
    }
    
    @objc func hide() {
        self.isHidden = true
        cancelDelayHide()
    }
    
    func cancelDelayHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
    }
    
    func beginDrag() {
        isDragged = true
    }
    
    func endDrag() {
        isDragged = false
    }
    
    func continueDrag() {
        refreshVideoControl()
    }
    
    @objc func refreshVideoControl() {
        guard let delegatePlayer = delegatePlayer else { return }

        let duration = delegatePlayer.duration
        let intDuration = duration + 0.5
        if intDuration > 0 {
            slider.maximumValue = Float(duration)
            totalDurationLabel.text = String(format: "%02d:%02d", Int(intDuration/60),Int(Int(intDuration)%60))
        }
        else {
            slider.maximumValue = 1
            totalDurationLabel.text = "--:--"
        }
        var position: TimeInterval
        if isDragged {
            position = TimeInterval(slider.value)
        }
        else {
            position = delegatePlayer.currentPlaybackTime
        }
        let intPosition = position + 0.5
        if intPosition > 0 {
            slider.value = Float(position)
        }
        else {
            slider.value = 0
        }
        currentTimeLabel.text = String(format: "%02d:%02d", Int(position/60),Int(Int(position)%60))
        let isPlaying = delegatePlayer.isPlaying()
        playBtn.isHidden = isPlaying
        pauseBtn.isHidden = !isPlaying
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshVideoControl), object: nil)
        if !overlayPanel.isHidden {
            self.perform(#selector(refreshVideoControl), with: nil, afterDelay: 0.4)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
