//
//  ShareFileCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/25.
//

import UIKit

class ShareFileCell: UICollectionViewCell,ReusableView {
    //图标
    lazy var iconView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage()
    }
    
    //状态Label
    lazy var fileNameLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.backgroundColor = .custom(.white_ffffff)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconView)
        contentView.addSubview(fileNameLabel)
    }
     
    private func setConstrains() {
        iconView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(10))
            $0.width.height.equalTo(ZTScaleValue(50))
        }
        
        fileNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iconView.snp.bottom).offset(ZTScaleValue(15))
            $0.left.right.equalToSuperview()
        }

    }
}
