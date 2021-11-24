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

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(5))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-5))
            $0.left.equalToSuperview().offset(ZTScaleValue(16))
            $0.right.equalToSuperview().offset(ZTScaleValue(-16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
