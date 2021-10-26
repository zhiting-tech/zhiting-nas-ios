//
//  StoragePoolCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/28.
//

import UIKit

class StoragePoolCell: UICollectionViewCell, ReusableView {
    var menuCallback: (() -> ())?
    /// statusCover 按钮回调
    var statusCoverCallback: ((_ index: Int) -> ())? {
        didSet {
            statusCover?.btnCallback = statusCoverCallback
        }
    }
    
    var storagePool: StoragePoolModel? {
        didSet {
            guard let pool = storagePool else { return }
            nameLabel.text = pool.name
            sizeLabel.text = "\(ZTCTool.convertFileSize(size: pool.capacity))"
            
            /// 存储池状态cover
            if pool.status != "" {
                menuBtn.isHidden = true
                statusCover = StatusCoverView()
                contentView.addSubview(statusCover!)
                statusCover?.setStatus(pool)
                statusCover?.btnCallback = statusCoverCallback
                statusCover?.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            } else {
                menuBtn.isHidden = false
                statusCover?.removeFromSuperview()
            }

        }
    }

    private var statusCover: StatusCoverView?

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_storagePool)
    }
    
    private lazy var menuBtn = Button().then {
        $0.setImage(.assets(.icon_menu), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }

    
    private lazy var nameLabel = UILabel().then {
        $0.font = .font(size: 16.ztScaleValue, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "存储池".localizedString
    }
    
    private lazy var sizeLabel = UILabel().then {
        $0.font = .font(size: 11.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "0GB".localizedString
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
        contentView.addSubview(sizeLabel)

    }
    
    private func setupConstraints() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19.ztScaleValue)
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
            $0.top.equalTo(icon.snp.bottom).offset(28.ztScaleValue)
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        sizeLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5.ztScaleValue)
            $0.left.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-20.ztScaleValue)
        }
        
    }

}
