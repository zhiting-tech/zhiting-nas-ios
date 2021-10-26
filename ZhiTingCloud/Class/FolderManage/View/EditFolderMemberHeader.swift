//
//  EditFolderMemberHeader.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/2.
//

import UIKit

class EditFolderMemberHeader: UIView {
    lazy var titleLabel = UILabel().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.text = "可访问成员"
        $0.font = .font(size: 14, type: .regular)
    }
    
    
    lazy var addButton = Button().then {
        $0.setImage(.assets(.storage_add), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(addButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(22)
            $0.width.equalTo(35)
        }

    }

    
}
