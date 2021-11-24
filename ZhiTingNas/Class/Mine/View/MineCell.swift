//
//  MineCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/28.
//

import UIKit

class MineCell: UITableViewCell, ReusableView {
    enum MineCellType {
        /// 存储管理
        case storage
        /// 文件夹管理
        case document
    }

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var title = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }

    private lazy var arrow = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.arrow_right)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    convenience init(type: MineCellType) {
        self.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: Self.reusableIdentifier)
        switch type {
        case .storage:
            title.text = "存储管理".localizedString
            icon.image = .assets(.mine_storage)
        case .document:
            title.text = "文件夹管理".localizedString
            icon.image = .assets(.mine_doc)
        }
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(icon)
        contentView.addSubview(title)
        contentView.addSubview(arrow)
        contentView.addSubview(line)
    }
    
    private func setConstraints() {
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.height.equalTo(20.ztScaleValue).priority(.high)
            $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(14.ztScaleValue)
            $0.width.equalTo(8.ztScaleValue)
        }

        title.snp.makeConstraints {
            $0.centerY.equalTo(icon.snp.centerY)
            $0.left.equalTo(icon.snp.right).offset(12.ztScaleValue)
            $0.right.equalTo(arrow.snp.left).offset(-12.ztScaleValue)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(14.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(0.5)
        }
        
        

    }
    
}
