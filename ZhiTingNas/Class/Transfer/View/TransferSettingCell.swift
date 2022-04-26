//
//  TransferSettingCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/11/30.
//

import UIKit

class TransferSettingCell: UITableViewCell, ReusableView {
    var callback: (() -> ())?

    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var detailLabel = UILabel().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var valueLabel = UILabel().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.textAlignment = .right
    }
    
    lazy var btn = Button().then {
        $0.setImage(.assets(.arrow_right), for: .normal)
    }

    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstranits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(btn)
        contentView.addSubview(line)
        
        valueLabel.isUserInteractionEnabled = true
        valueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapValue)))

        btn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.callback?()
        }
    }
    
    @objc private func tapValue() {
        callback?()
    }

    private func setupConstranits() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.left.equalToSuperview().offset(16)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(18)
            $0.left.equalToSuperview().offset(16)
        }
        
        btn.snp.makeConstraints {
            $0.centerY.equalTo(detailLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-16)
            $0.width.equalTo(7.5)
            $0.height.equalTo(13.5)
        }
        
        valueLabel.snp.makeConstraints {
            $0.right.equalTo(btn.snp.left).offset(-11)
            $0.left.equalTo(detailLabel.snp.right).offset(5)
            $0.centerY.equalTo(detailLabel.snp.centerY)
        }

        line.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(19)
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(10)
        }

    }

}
