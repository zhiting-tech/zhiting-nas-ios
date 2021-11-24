//
//  UserAgreementAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/11/4.
//

import UIKit

class UserAgreementAlertView: UIView {
    
    @UserDefaultBool("IsAgreeUserAgreement")
    var isAgreeUserAgreement: Bool
    
    var userAgreementCallback: ((_ tap: Int) -> ())?//0:用户协议，1:隐私政策
    
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var tipsDescriptionLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.textAlignment = .left
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.attributed.text = """
        \("欢迎使用“智汀云盘”!\n我们非常重视您的个人信息和隐私保护。在您使用“智汀云盘”服务之前，请仔细阅读、充分理解并同意智汀云盘的", .paragraph(.lineSpacing(10)),  .font(.font(size: ZTScaleValue(14),   type: .medium)), .foreground(.custom(.black_3f4663)))\("《用户协议》", .font(.font(size: ZTScaleValue(14), type: .medium)), .foreground(.custom(.blue_2da3f6)), .action(clickUserAreement))\("与",.paragraph(.lineSpacing(10)),  .font(.font(size: ZTScaleValue(14), type: .medium)), .foreground(.custom(.black_3f4663)))\("《隐私政策》", .font(.font(size: ZTScaleValue(14), type: .medium)), .foreground(.custom(.blue_2da3f6)), .action(clickPrivacy))
        """
        $0.attributed.text?.add(attributes: [])
    }

    private func clickUserAreement(){
        print("点击《用户授权协议》")
        userAgreementCallback?(0)
    }
    
    private func clickPrivacy(){
        print("点击《隐私政策》")
        userAgreementCallback?(1)
    }

    
    private lazy var sureBtn = Button().then {
        
        $0.setTitle("同意".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
        }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("不同意".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.isAgreeUserAgreement = false
            exit(0)
        }

        
    }

    @objc private func onClickSure() {
        isAgreeUserAgreement = true
        removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, message: String) {
        self.init(frame: frame)
        self.tipsLabel.text = message
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
        container.addSubview(tipsDescriptionLabel)
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
            $0.top.equalToSuperview().offset(ZTScaleValue(22))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        tipsDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(21))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.right.equalToSuperview()
            $0.top.equalTo(tipsDescriptionLabel.snp.bottom).offset(ZTScaleValue(25))
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.left.equalToSuperview()
            $0.top.equalTo(tipsDescriptionLabel.snp.bottom).offset(ZTScaleValue(25))
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    @discardableResult
    static func show(target: UIViewController, message: String, userAgreementCallback: ((_ tap: Int) -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> UserAgreementAlertView {
        let tipsView = UserAgreementAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: message)
        tipsView.tipsLabel.text = message
        tipsView.userAgreementCallback = userAgreementCallback
        target.view.addSubview(tipsView)
        target.view.bringSubviewToFront(tipsView)
//        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }

}
