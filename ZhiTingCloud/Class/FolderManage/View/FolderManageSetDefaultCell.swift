//
//  FolderManageSetDefaultCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/30.
//

import UIKit

class FolderManageSetDefaultCell: UITableViewCell, ReusableView {
    var nameLabelCallback: (() -> ())?

    private lazy var lineTop = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "默认储存分区".localizedString
        
    }

    private lazy var detailLabel = UILabel().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "有新成员加入时，系统会自动建该成员的私人文件夹，并放在默认存储分区".localizedString
        $0.numberOfLines = 0
    }
    
    lazy var nameLabel = UILabel().then {
        $0.text = "系统存储池-默认分区"
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 14, type: .bold)
        $0.textAlignment = .right
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapNameLabel)))
    }

    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.arrow_down)
    }

    private lazy var lineBottom = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
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
        contentView.addSubview(lineTop)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(detailLabel)
        contentView.addSubview(lineBottom)
    }
    
    private func setupConstraints() {
        lineTop.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(lineTop.snp.bottom).offset(20.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.equalTo(100.ztScaleValue)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
            $0.width.equalTo(8.ztScaleValue)
            $0.height.equalTo(4.ztScaleValue)
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.right).offset(10)
            $0.right.equalTo(arrow.snp.left).offset(-5)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }

        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }

        lineBottom.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(25.ztScaleValue)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
            $0.bottom.equalToSuperview()
        }

    }

    @objc
    private func tapNameLabel() {
        nameLabelCallback?()
    }
    
}
