//
//  SingleTipsAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/8/5.
//

import UIKit

class SingleTipsAlertView: UIView {
    var sureCallback: (() -> ())? {
        didSet {
            sureBtn.clickCallBack = { [weak self] _ in
                self?.sureCallback?()
            }
        }
    }

    private lazy var bgView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    
    private lazy var detailLabel = UILabel().then {
        $0.text = "正在保存分区信息，需要一些时间处理。已为您后台运行，可返回列表刷新查看。"
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.numberOfLines = 0
    }
    
    lazy var sureBtn = LoadingButton().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.waitingView.progressColor = .custom(.blue_427aed)
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitle("确定", for: .normal)
        $0.titleColor = .custom(.white_ffffff)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
    }
    

    convenience init(detail: String,
                     detailColor: UIColor = .custom(.black_3f4663),
                     sureBtnTitle: String) {
        self.init()
        detailLabel.text = detail
        detailLabel.textColor = detailColor
        sureBtn.setTitle(sureBtnTitle, for: .normal)
    }

}

extension SingleTipsAlertView {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()

    }
    
    private func setupViews() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(detailLabel)
        containerView.addSubview(sureBtn)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 70.ztScaleValue)
        }
                
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        sureBtn.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(24.5.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100.ztScaleValue)
            $0.height.equalTo(40.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-20.ztScaleValue)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 1
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    @objc private func close() {
        removeFromSuperview()
    }
}
