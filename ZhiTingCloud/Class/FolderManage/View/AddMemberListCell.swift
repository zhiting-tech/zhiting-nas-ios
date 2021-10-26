//
//  AddMemberListCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/7.
//

import UIKit

class AddMemberListCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else { return }
            nicknameLabel.text = member.nickname
            selectIcon.image = (member.isSelected ?? false) ? .assets(.shareSelected_selected) : .assets(.shareSelected_normal)
        }
    }

    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.user_default)
        $0.layer.cornerRadius = 20.ztScaleValue
    }
    
    private lazy var nicknameLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.text = "user"
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var selectIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.shareSelected_normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(avatar)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(selectIcon)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.width.height.equalTo(40.ztScaleValue).priority(.high)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
        
        selectIcon.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.height.width.equalTo(16.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }

        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.left.equalTo(avatar.snp.right).offset(15.ztScaleValue)
            $0.right.equalTo(selectIcon.snp.left).offset(-15.ztScaleValue)
        }


    }

}
