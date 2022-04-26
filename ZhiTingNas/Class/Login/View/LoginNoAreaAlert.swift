//
//  LoginNoAreaAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2022/1/10.
//

import UIKit
import AttributedString


class LoginNoAreaAlert: UIView {
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
    
    private lazy var warningIcon = ImageView().then {
        $0.image = .assets(.icon_warning)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var detailLabel = UILabel().then {
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.numberOfLines = 0
    }
    
    lazy var sureBtn = LoadingButton().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.waitingView.progressColor = .custom(.blue_427aed)
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitle("知道了", for: .normal)
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

extension LoginNoAreaAlert {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()

    }
    
    private func setupViews() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(warningIcon)
        containerView.addSubview(detailLabel)
        containerView.addSubview(sureBtn)
        
        
        let str1 = ASAttributedString(
            "\("拥有者已设置不能通过账号密码登录\n\n".localizedString)",
            with: [
                .font(.font(size: 16, type: .bold)),
                .foreground(.custom(.black_3f4663)),
                .paragraph(.alignment(.center))
            ])
        
        let str2 = ASAttributedString(
            "\("如需继续，请按以下方式设置：\n".localizedString)",
            with: [
                .font(.font(size: 14, type: .bold)),
                .foreground(.custom(.black_3f4663)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        let str3 = ASAttributedString(
            "\(.image(.assets(.number_1) ?? Image())) \("请联系对应家庭/公司的拥有者，按以下路径设置“允许获取智汀云盘凭证”\n".localizedString)",
            with: [
                .font(.font(size: 14, type: .regular)),
                .foreground(.custom(.black_3f4663)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        let str4 = ASAttributedString(
            "\("路径：专业版-智慧中心-设备详情-高级设置-用户凭证-允许获取\n\n".localizedString)",
            with: [
                .font(.font(size: 14, type: .regular)),
                .foreground(.custom(.gray_94a5be)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        let str5 = ASAttributedString(
            "\(.image(.assets(.number_2) ?? Image())) \("返回登录页面，通过“智汀家庭云”APP授权登录\n".localizedString)",
            with: [
                .font(.font(size: 14, type: .regular)),
                .foreground(.custom(.black_3f4663)),
                .paragraph(.alignment(.left), .lineSpacing(5))
            ])
        
        let str = str1 + str2 + str3 + str4 + str5

        detailLabel.attributed.text = str
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 70.ztScaleValue)
        }
        
        warningIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(57)
        }
                
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(warningIcon.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        sureBtn.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(24.5.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100.ztScaleValue)
            $0.height.equalTo(40)
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
