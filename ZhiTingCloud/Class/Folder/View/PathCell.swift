//
//  PathCell.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/31.
//

import UIKit

class PathCell: UICollectionViewCell,ReusableView {
    
    lazy var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingHead
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
    }
    
    lazy var arrowImgview = ImageView().then {
        $0.image = .assets(.path_arrow)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImgview)
    }
     
    private func setConstrains() {
        titleLabel.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.width.greaterThanOrEqualTo(ZTScaleValue(20))
//            $0.height.equalTo(ZTScaleValue(20))
        }
        
        arrowImgview.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.right).offset(ZTScaleValue(10))
            $0.right.equalToSuperview().offset(-ZTScaleValue(5)).priority(.high)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.width.equalTo(ZTScaleValue(5))
            $0.height.equalTo(ZTScaleValue(10))
        }
        
        
    }
    
}
