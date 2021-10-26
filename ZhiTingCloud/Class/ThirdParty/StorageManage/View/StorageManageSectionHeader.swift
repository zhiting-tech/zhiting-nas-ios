//
//  StorageManageSectionHeader.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/29.
//

import UIKit

class StorageManageSectionHeader: UICollectionReusableView, ReusableView {
    lazy var title = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-5.ztScaleValue)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
