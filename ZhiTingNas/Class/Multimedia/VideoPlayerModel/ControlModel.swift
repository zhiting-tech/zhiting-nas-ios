//
//  ControlModel.swift
//  ijkswift
//
//  Created by 左权 on 2018/9/19.
//  Copyright © 2018年 YTTV. All rights reserved.
//

import UIKit

struct ControlModel {

    let topPanel = UIView.init()
    let bottomPanel = UIView.init()
    let overlayPanel = UIView.init()
    
    let backBtn = Button()
    let titleLabel = UILabel.init()
    
    let playBtn = UIButton.init()
    let pauseBtn = UIButton.init()
    let currentTimeLabel = UILabel.init()
    let totalDurationLabel = UILabel.init()
    let slider = UISlider.init()
    var fullScreenBtn = Button().then {
        $0.setImage(.assets(.fullScreen), for: .normal)
        $0.isEnhanceClick = true
    }//全屏按钮

    

    
    func initUI() {
        backBtn.setImage(.assets(.back_white), for: .normal)
        backBtn.isEnhanceClick = true
        
        totalDurationLabel.backgroundColor = UIColor.clear
        totalDurationLabel.textColor = .custom(.white_ffffff)
        totalDurationLabel.textAlignment = .right
        totalDurationLabel.font = .font(size: 11.ztScaleValue, type: .bold)

        currentTimeLabel.backgroundColor = UIColor.clear
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = .font(size: 11.ztScaleValue, type: .bold)

        playBtn.setImage(.assets(.playBtn), for: .normal)
        pauseBtn.setImage(.assets(.stopBtn), for: .normal)
        slider.setThumbImage(.assets(.thumbImage), for: .normal)
    }
    
    func layoutUI(view: UIView) {
        view.addSubview(overlayPanel)
        overlayPanel.addSubview(topPanel)
        overlayPanel.addSubview(bottomPanel)
        overlayPanel.addSubview(playBtn)
        overlayPanel.addSubview(pauseBtn)

        topPanel.addSubview(backBtn)
        topPanel.addSubview(titleLabel)
        bottomPanel.addSubview(currentTimeLabel)
        bottomPanel.addSubview(slider)
        bottomPanel.addSubview(totalDurationLabel)
        bottomPanel.addSubview(fullScreenBtn)
        
        overlayPanel.snp.makeConstraints {
            $0.left.right.bottom.equalTo(view)
            $0.top.equalTo(view).offset(Screen.statusBarHeight)
        }
        topPanel.snp.makeConstraints {
            $0.left.right.top.equalTo(overlayPanel)
            $0.height.equalTo(Screen.k_nav_height)
        }
        bottomPanel.snp.makeConstraints {
            $0.left.right.bottom.equalTo(overlayPanel)
            $0.size.height.equalTo(60.ztScaleValue)
        }
        
        backBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.size.equalTo(CGSize(width: 8.ztScaleValue, height: 14.ztScaleValue))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(backBtn.snp.right).offset(8.ztScaleValue)
        }
        
        playBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 70.ztScaleValue, height: 70.ztScaleValue))
        }
        
        pauseBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 70.ztScaleValue, height: 70.ztScaleValue))
        }
        
        currentTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(bottomPanel)
            $0.left.equalTo(bottomPanel).offset(15.ztScaleValue)
            $0.width.lessThanOrEqualTo(100.ztScaleValue)
        }
        totalDurationLabel.snp.makeConstraints {
            $0.centerY.equalTo(bottomPanel)
            $0.right.equalTo(fullScreenBtn.snp.left).offset(-18.ztScaleValue)
            $0.width.lessThanOrEqualTo(100.ztScaleValue)
        }
        
        fullScreenBtn.snp.makeConstraints {
            $0.centerY.equalTo(bottomPanel)
            $0.right.equalTo(bottomPanel).offset(-15.ztScaleValue)
            $0.width.height.equalTo(16.ztScaleValue)
        }
        slider.snp.makeConstraints {
            $0.centerY.equalTo(bottomPanel)
            $0.left.equalTo(currentTimeLabel.snp.right).offset(6.5.ztScaleValue)
            $0.right.equalTo(totalDurationLabel.snp.left).offset(-6.5.ztScaleValue)
        }
    }
    
}
