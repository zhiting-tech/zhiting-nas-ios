//
//  HardDiskCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/28.
//

import UIKit

class HardDiskCell: UICollectionViewCell, ReusableView {
    var addBtnCallback: (() -> ())?
    
    var hardDisk: PhysicalVolume? {
        didSet {
            guard let hardDisk = hardDisk else { return }
            nameLabel.text = hardDisk.name
            sizeLabel.text = "\(ZTCTool.convertFileSize(size: hardDisk.capacity))"
        }
    }

    lazy var bgView = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.hardDrive_bg1)
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_hardDrive)
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.font = .font(size: 20.ztScaleValue, type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.text = "闲置硬盘"
    }
    
    private lazy var sizeLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .medium)
        $0.textColor = .custom(.white_ffffff)
        $0.text = "0GB"
    }
    
    lazy var addButton = Button().then {
        $0.setTitle("添加到储存池".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10.ztScaleValue
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
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
        layer.cornerRadius = 10
        clipsToBounds = true
        addButton.clickCallBack = { [weak self] _ in
            self?.addBtnCallback?()
        }
        contentView.addSubview(bgView)
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(addButton)
        
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19.ztScaleValue)
            $0.left.equalToSuperview().offset(27.ztScaleValue)
            $0.height.width.equalTo(34.ztScaleValue)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(10.ztScaleValue)
            $0.left.equalToSuperview().offset(27.ztScaleValue)
            $0.right.equalToSuperview().offset(-10)
        }
        
        sizeLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.left.equalToSuperview().offset(27.ztScaleValue)
            $0.right.equalToSuperview().offset(-10)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(sizeLabel.snp.bottom).offset(15.ztScaleValue)
            $0.left.equalToSuperview().offset(27.ztScaleValue)
            $0.height.equalTo(50.ztScaleValue)
            $0.right.equalToSuperview().offset(-26.5.ztScaleValue)
//            $0.bottom.equalToSuperview().offset(-20.ztScaleValue)
        }



    }

}
