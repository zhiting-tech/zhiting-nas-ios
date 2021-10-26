//
//  FolderManageProcessAlert.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/5.
//

import UIKit

class FolderManageProcessAlert: UIView {

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
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.numberOfLines = 0
    }
    

    /// processBottomView
    private lazy var processBottomView = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }

    private lazy var processLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "修改需要一段时间"
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 16.ztScaleValue, type: .bold)
    }
    
    private lazy var progressView = UIProgressView().then {
        $0.progressTintColor = .custom(.green_01dbc0)
        $0.layer.cornerRadius = 4.ztScaleValue
        $0.backgroundColor = .custom(.white_ffffff)
        $0.progress = 0.4
    }

}

extension FolderManageProcessAlert {
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
        
        processBottomView.addSubview(processLabel)
        processBottomView.addSubview(progressView)

        containerView.addSubview(processBottomView)


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
        

        processBottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(detailLabel.snp.bottom).offset(22.5.ztScaleValue)
        }
        
        processLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18.5.ztScaleValue)
            $0.centerX.equalToSuperview()
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(processLabel.snp.bottom).offset(14.ztScaleValue)
            $0.left.equalToSuperview().offset(23.ztScaleValue)
            $0.right.equalToSuperview().offset(-23.ztScaleValue)
            $0.height.equalTo(8.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-26.5.ztScaleValue)
                
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
