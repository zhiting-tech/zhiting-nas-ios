//
//  TipsAlertView.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/5.
//

import UIKit

class TipsAlertView: UIView {
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
    
    private lazy var titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "存储分区转移"
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 16.ztScaleValue, type: .bold)
    }
    
    private lazy var detailLabel = UILabel().then {
        $0.text = "海棠阁2401存储分区从“共享-私人分区”改为“共享-家庭专用分区”"
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.numberOfLines = 0
    }


    private lazy var tipsLabel = UILabel().then {
        $0.text = "确定要修改吗？修改预计需要一段时间处理，且不可暂停（暂停会导致文件存储在两个不同分区）"
        $0.textColor = .custom(.red_fe0000)
        $0.textAlignment = .center
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.numberOfLines = 0
    }
    
    /// optionBottomView
    private lazy var optionBottomView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var line0 = UIView().then {
        $0.backgroundColor = .custom(.gray_dddddd)
    }
    
    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_dddddd)
    }

    lazy var sureBtn = LoadingButton().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.waitingView.progressColor = .custom(.blue_427aed)
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitle("确定", for: .normal)
        $0.titleColor = .custom(.blue_427aed)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
    }
    
    private lazy var cancelBtn = Button().then {
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitle("取消", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }


    convenience init(title: String,
                     titleColor: UIColor = .custom(.black_3f4663),
                     detail: String,
                     detailColor: UIColor = .custom(.black_3f4663),
                     warning: String,
                     warningColor: UIColor = .custom(.red_fe0000),
                     sureBtnTitle: String) {
        self.init()
        titleLabel.text = title
        titleLabel.textColor = titleColor
        detailLabel.text = detail
        detailLabel.textColor = detailColor
        tipsLabel.text = warning
        tipsLabel.textColor = warningColor
        sureBtn.setTitle(sureBtnTitle, for: .normal)

    }

}

extension TipsAlertView {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()

    }
    
    private func setupViews() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        containerView.addSubview(tipsLabel)
        
        optionBottomView.addSubview(cancelBtn)
        optionBottomView.addSubview(sureBtn)
        optionBottomView.addSubview(line0)
        optionBottomView.addSubview(line1)

        containerView.addSubview(optionBottomView)


    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 70.ztScaleValue)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.ztScaleValue)
            $0.centerX.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17.5.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }

        optionBottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(tipsLabel.snp.bottom).offset(22.5.ztScaleValue)
        }

        line0.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        line1.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(0.5)
            $0.height.equalTo(50.ztScaleValue)
        }

        cancelBtn.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview()
            $0.right.equalTo(line1.snp.left)
        }

        sureBtn.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.left.equalTo(line1.snp.right)
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
