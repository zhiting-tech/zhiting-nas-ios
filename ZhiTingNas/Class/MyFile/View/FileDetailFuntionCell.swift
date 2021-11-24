//
//  FileDetailFuntionCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/20.
//

import UIKit

class FileDetailFuntionCell: UICollectionViewCell,ReusableView {
    lazy var funtionImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.myFile_tab)
    }
    
    lazy var funtionTitleLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        self.layer.cornerRadius = ZTScaleValue(10)
        self.backgroundColor = .custom(.gray_eeeeee)
        contentView.addSubview(funtionImgView)
        contentView.addSubview(funtionTitleLabel)
    }
    
    private func setConstrains(){
        funtionImgView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(ZTScaleValue(36))
            $0.width.height.equalTo(ZTScaleValue(22))
        }
        funtionTitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(funtionImgView.snp.bottom).offset(ZTScaleValue(14.5))
            $0.left.right.equalToSuperview()
        }
    }
}
