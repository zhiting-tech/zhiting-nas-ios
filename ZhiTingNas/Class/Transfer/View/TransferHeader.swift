//
//  TransferHeader.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/22.
//

import UIKit

class TransferHeader: UITableViewHeaderFooterView, ReusableView {
    lazy var label = UILabel().then {
        $0.font = .font(size: 12, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .left
    }
    
    lazy var button = Button().then {
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.setTitle("清空".localizedString, for: .normal)
        $0.titleLabel?.font = .font(size: 12, type: .bold)
        $0.isEnhanceClick = true
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView?.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(label)
        contentView.addSubview(button)
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-5.ztScaleValue)
            $0.left.equalToSuperview().offset(16.ztScaleValue)
            $0.right.equalToSuperview().offset(-16.ztScaleValue)
        }
        button.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.right.equalToSuperview().offset(-19.ztScaleValue)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
