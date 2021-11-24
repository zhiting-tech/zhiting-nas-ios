//
//  DocumentManageSetDefaultCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/30.
//

import UIKit

class FolderManageSetDeleteCell: UITableViewCell, ReusableView {

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "自动删除".localizedString
        
    }

    private lazy var detailLabel = UILabel().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "成员退出或被移除，他的私人文件夹及其文件是否自动删除".localizedString
        $0.numberOfLines = 0
    }
    
    lazy var switchBtn = SwitchButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))

    private lazy var lineBottom = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchBtn)
        contentView.addSubview(detailLabel)
        contentView.addSubview(lineBottom)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.width.equalTo(100.ztScaleValue)
        }
        
        switchBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(18.ztScaleValue)
            $0.width.equalTo(36.ztScaleValue)
        }
        

        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }

        lineBottom.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(25.ztScaleValue)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
            $0.bottom.equalToSuperview()
        }

    }

    
}
