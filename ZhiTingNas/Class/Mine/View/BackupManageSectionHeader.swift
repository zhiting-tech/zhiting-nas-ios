//
//  BackupManageSectionHeader.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/12/16.
//

import Foundation
import UIKit

class BackupManageSectionHeader: UITableViewHeaderFooterView, ReusableView {
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    lazy var label = UILabel().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .left
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView?.backgroundColor = .custom(.white_ffffff)
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(label)
        contentView.addSubview(line)
        
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16.ztScaleValue)
            $0.right.equalToSuperview().offset(-16.ztScaleValue)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
