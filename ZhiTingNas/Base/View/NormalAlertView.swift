//
//  NormalAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/11/25.
//

import UIKit

class NormalAlertView: UIView {
    
    var clickCallback: ((_ tap: Int) -> ())?

    var removeWithSure = true
    
    var isSureBtnLoading = false
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.text = "温馨提示".localizedString
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
            
    private lazy var detailLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.text = "该文件过大，建议下载本地后进行查看".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    

    

    
    private lazy var sureBtn = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.clickCallback?(1)
            self?.removeFromSuperview()
        }
    }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("取消".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.clickCallback?(0)
            self?.removeFromSuperview()
        }

    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, title: String, message: String, leftTap:String, rightTap:String) {
        self.init(frame: frame)
        self.tipsLabel.text = title
        self.detailLabel.text = message
        self.cancelBtn.setTitle(leftTap.localizedString, for: .normal)
        self.sureBtn.setTitle(rightTap.localizedString, for: .normal)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        
        container.addSubview(tipsLabel)
        container.addSubview(detailLabel)
                
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(75))
        }
        
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(12))
            $0.left.equalToSuperview().offset(ZTScaleValue(24.5))
            $0.right.equalToSuperview().offset(ZTScaleValue(-24.5))
        }
        
        
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.right.equalToSuperview()
            $0.top.equalTo(detailLabel.snp.bottom).offset(25.ztScaleValue)
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview()
            $0.top.equalTo(detailLabel.snp.bottom).offset(25.ztScaleValue)
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
            $0.bottom.equalToSuperview()
        }

    }
    
    @discardableResult
    static func show(title: String, message: String, leftTap:String, rightTap:String,clickCallback: ((_ tap: Int) -> ())?, removeWithSure: Bool = true) -> NormalAlertView {
        let tipsView = NormalAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), title: title, message: message, leftTap: leftTap, rightTap: rightTap)
        tipsView.removeWithSure = removeWithSure
        tipsView.clickCallback = clickCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }

}
