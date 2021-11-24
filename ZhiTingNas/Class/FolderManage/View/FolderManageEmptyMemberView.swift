//
//  FolderManageEmptyMemberView.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/6.
//

import UIKit

class FolderManageEmptyMemberView: UIView {

    private lazy var icon = ImageView().then {
        $0.image = .assets(.empty_member)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var addBtn = Button().then {
        $0.setTitle("添加成员", for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.custom(.blue_2da3f6).cgColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(addBtn)
        
        icon.snp.makeConstraints {
            $0.height.equalTo(92.ztScaleValue)
            $0.width.equalTo(110.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20.ztScaleValue)
        }
        
        addBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150.ztScaleValue)
            $0.top.equalTo(icon.snp.bottom).offset(25.ztScaleValue)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class AddMemberEmptyView: UIView {

    private lazy var icon = ImageView().then {
        $0.image = .assets(.empty_member)
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var tipsLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.numberOfLines = 0
        $0.text = "请在下方列表选择成员\n选择成员后可设置成员权限"
    }
    
    lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_down_double)
        $0.contentMode = .scaleAspectFit
        
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .custom(.white_ffffff)
        addSubview(icon)
        addSubview(tipsLabel)
        addSubview(arrow)

        
        icon.snp.makeConstraints {
            $0.height.equalTo(92.ztScaleValue)
            $0.width.equalTo(110.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(30.ztScaleValue)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.top.equalTo(icon.snp.bottom).offset(25.ztScaleValue)
        }

        arrow.snp.makeConstraints {
            $0.height.width.equalTo(18.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tipsLabel.snp.bottom).offset(30.ztScaleValue)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
