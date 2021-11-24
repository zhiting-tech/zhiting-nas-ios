//
//  FolderManageCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/30.
//

import UIKit

class FolderManageCell: UICollectionViewCell, ReusableView {
    /// menu按钮回调
    var menuCallback: (() -> ())?
    /// statusCover 按钮回调
    var statusCoverCallback: ((_ index: Int) -> ())? {
        didSet {
            statusCover?.btnCallback = statusCoverCallback
        }
    }
    
    var folder: FolderModel? {
        didSet {
            guard let folder = folder else {
                return
            }
            
            nameLabel.text = folder.name
            partitionLabel.text = "\(folder.pool_name ?? "")-\(folder.partition_name ?? "")"
            encryptIcon.isHidden = (folder.is_encrypt == 0)
            menuBtn.isEnabled = folder.is_encrypt == 1
            folder.is_encrypt == 1 ? menuBtn.setImage(.assets(.icon_menu_blue), for: .normal) : menuBtn.setImage(.assets(.icon_menu), for: .normal)
            if let persons = folder.persons, !persons.isEmpty {
                memberLabel.text = persons
            } else {
                memberLabel.text = " "
            }
            
            /// 文件夹状态cover
            if folder.status != "" {
                menuBtn.isHidden = true
                statusCover = StatusCoverView()
                contentView.addSubview(statusCover!)
                statusCover?.setStatus(folder)
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

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.folder_icon)
    }
    
    private lazy var encryptIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.encrypt_icon)
    }

    private lazy var menuBtn = Button().then {
        $0.setImage(.assets(.icon_menu), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }

    
    private lazy var nameLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "文件夹001".localizedString
    }

    private lazy var partitionIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.partition_icon)
    }

    private lazy var partitionLabel = UILabel().then {
        $0.font = .font(size: 12.ztScaleValue, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "共享-家庭专用分区"
    }
    
    private lazy var memberIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.member_icon)
    }

    private lazy var memberLabel = UILabel().then {
        $0.font = .font(size: 12.ztScaleValue, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "你、我、它、她、他、獭、塔、牠、沓、挞、遢".localizedString
    }
    
    private var statusCover: StatusCoverView?

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
        contentView.addSubview(encryptIcon)
        contentView.addSubview(menuBtn)
        contentView.addSubview(nameLabel)
        contentView.addSubview(partitionIcon)
        contentView.addSubview(partitionLabel)
        contentView.addSubview(memberIcon)
        contentView.addSubview(memberLabel)

    }
    
    private func setupConstraints() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.height.equalTo(36.ztScaleValue)
            $0.width.equalTo(33.5.ztScaleValue)
        }
        
        encryptIcon.snp.makeConstraints {
            $0.centerX.equalTo(icon.snp.right).offset(-5)
            $0.centerY.equalTo(icon.snp.bottom).offset(-5)
            $0.width.height.equalTo(16.ztScaleValue)
        }
        
        menuBtn.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(-10)
            $0.width.height.equalTo(22.ztScaleValue)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(16.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        partitionIcon.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.height.equalTo(12.ztScaleValue)
        }

        partitionLabel.snp.makeConstraints {
            $0.centerY.equalTo(partitionIcon.snp.centerY)
            $0.left.equalTo(partitionIcon.snp.right).offset(10.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }
        
        memberIcon.snp.makeConstraints {
            $0.top.equalTo(partitionIcon.snp.bottom).offset(10.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.height.equalTo(12.ztScaleValue)
        }

        memberLabel.snp.makeConstraints {
            $0.centerY.equalTo(memberIcon.snp.centerY)
            $0.left.equalTo(memberIcon.snp.right).offset(10.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-12.ztScaleValue)
        }
        
    }

}
