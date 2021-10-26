//
//  StoragePoolPartitionCell.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/7/5.
//

import UIKit

class StoragePoolPartitionCell: UICollectionViewCell, ReusableView {
    var menuCallback: (() -> ())?

    /// statusCover 按钮回调
    var statusCoverCallback: ((_ index: Int) -> ())? {
        didSet {
            statusCover?.btnCallback = statusCoverCallback
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_storagePoolPartition)
    }
    
    private lazy var menuBtn = Button().then {
        $0.setImage(.assets(.icon_menu), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }

    
    private lazy var nameLabel = UILabel().then {
        $0.font = .font(size: 16.ztScaleValue, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "默认存储池".localizedString
    }
    
    //总容量
    private lazy var allMemoryLabel = UILabel().then {
        $0.font = .font(size: 10.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "总容量: ".localizedString
    }
    
    //可用容量
    private lazy var allocableMemoryLabel = UILabel().then {
        $0.font = .font(size: 10.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "可用容量: ".localizedString
    }

    //状态view
    private var statusCover: StatusCoverView?


    lazy var allProgressView = UIView().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
    }
    
    lazy var allocableProgressView = UIView().then {
        $0.backgroundColor = .custom(.green_01dbc0)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
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
        backgroundColor = .custom(.gray_f2f5fa)
        clipsToBounds = true
        layer.cornerRadius = 10
        
        menuBtn.clickCallBack = { [weak self] _ in
            self?.menuCallback?()
        }
        
        contentView.addSubview(icon)
        contentView.addSubview(menuBtn)
        contentView.addSubview(nameLabel)
        contentView.addSubview(allMemoryLabel)
        contentView.addSubview(allocableMemoryLabel)
        contentView.addSubview(allProgressView)
        contentView.addSubview(allocableProgressView)
    }
    
    public func setModel(model:LogicVolume){
        nameLabel.text = model.name
        allMemoryLabel.text = "总容量:".localizedString + ZTCTool.convertFileSize(size: model.capacity)
        allocableMemoryLabel.text = "可用容量: ".localizedString + ZTCTool.convertFileSize(size: model.capacity - model.use_capacity)
        allocableProgressView.snp.remakeConstraints {
            $0.left.top.height.equalTo(allProgressView)
            $0.width.equalTo(allProgressView).multipliedBy(CGFloat(model.use_capacity)/CGFloat(model.capacity))
        }
        
        /// 存储池状态cover
        if model.status != "" {
            menuBtn.isHidden = true
            statusCover = StatusCoverView()
            contentView.addSubview(statusCover!)
            statusCover?.setStatus(model)
            statusCover?.btnCallback = statusCoverCallback
            statusCover?.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            menuBtn.isHidden = false
            statusCover?.removeFromSuperview()
        }


    }
    
    private func setupConstraints() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18.ztScaleValue)
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.height.equalTo(36.ztScaleValue)
            $0.width.equalTo(33.5.ztScaleValue)
        }
        
        menuBtn.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(-10)
            $0.width.height.equalTo(22.ztScaleValue)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(20.ztScaleValue)
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        allMemoryLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10.ztScaleValue)
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
            $0.height.equalTo(ZTScaleValue(10))
        }
        
        allocableMemoryLabel.snp.makeConstraints {
            $0.top.equalTo(allMemoryLabel.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-25.ztScaleValue)
        }
        
        allProgressView.snp.makeConstraints {
            $0.top.equalTo(allocableMemoryLabel.snp.bottom).offset(ZTScaleValue(8))
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
            $0.height.equalTo(ZTScaleValue(5))
        }
        
        let width = 0
        
        allocableProgressView.snp.makeConstraints {
            $0.left.top.height.equalTo(allProgressView)
            $0.width.equalTo(width)
        }
    }
    
    override func prepareForReuse() {
        statusCover?.removeFromSuperview()
        
    }
}

