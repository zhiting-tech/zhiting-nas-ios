//
//  BackupManageCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/12/16.
//

import Foundation


class BackupManageCell: UITableViewCell, ReusableView {

    lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "".localizedString
        
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
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchBtn)
        contentView.addSubview(lineBottom)
    }
    
    private func setupConstraints() {
        icon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(22)
            $0.left.equalToSuperview().offset(18)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(8)
            $0.right.equalTo(switchBtn.snp.left).offset(-15)
        }
        
        switchBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(18)
            $0.width.equalTo(36)
        }

        lineBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }

    }

    
}
