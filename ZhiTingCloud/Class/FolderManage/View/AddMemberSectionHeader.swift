//
//  AddMemberSectionHeader.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/7.
//

import UIKit


class AddMemberSectionHeader: UIView, ReusableView {
    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        backgroundColor = .custom(.white_ffffff)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
