//
//  MineUserInfoHeaderView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/21.
//

import UIKit

class MineUserInfoHeaderView: UIView {
    var tapSelectArea: (() -> ())?

    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(24.0), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "选择家庭"
        $0.lineBreakMode = .byTruncatingTail
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectArea)))
    }

    lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_down)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectArea)))
    }

    lazy var userIcon = ImageView().then {
        $0.image = .assets(.user_default)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    lazy var userName = UILabel().then {
        $0.font = .font(size: ZTScaleValue(18), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = ""
        $0.lineBreakMode = .byTruncatingTail
        $0.isUserInteractionEnabled = true
    }
    
    lazy var settingBtn = Button().then {
        $0.setImage(.assets(.setting_icon), for: .normal)
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        addSubview(settingBtn)
        addSubview(userIcon)
        addSubview(userName)
        addSubview(titleLabel)
        addSubview(arrow)

    }
    
    @objc private func tap() {
        print("点击头像")
    }
    
    @objc private func selectArea() {
        print("点击选择家庭")
        tapSelectArea?()
    }
    
    private func setConstrains() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(settingBtn.snp.centerY)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.lessThanOrEqualTo(settingBtn.snp.left).offset(-44)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY).offset(2)
            $0.height.equalTo(13.5)
            $0.width.equalTo(8)
            $0.left.equalTo(titleLabel.snp.right).offset(14)
        }

        settingBtn.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(15)+Screen.statusBarHeight)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(28))
            
        }
        
        userIcon.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(60))
            $0.bottom.equalToSuperview()
        }
        
        userName.snp.makeConstraints {
            $0.centerY.equalTo(userIcon)
            $0.left.equalTo(userIcon.snp.right).offset(ZTScaleValue(17))
            $0.right.equalToSuperview().offset(-ZTScaleValue(-10))
        }
    }

}
