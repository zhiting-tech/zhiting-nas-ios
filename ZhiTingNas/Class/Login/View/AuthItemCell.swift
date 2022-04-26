//
//  AuthItemCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/12/13.
//

import UIKit

class AuthItemCell: UITableViewCell, ReusableView {
    
    var authItem: AreasTokenModel? {
        didSet {
            guard let item = authItem else { return }
            label.text = item.area_name
            if item.isSelected {
                icon.image = .assets(.areas_icon_selected)
                selectedIcon.isHidden = false
                label.textColor = .custom(.blue_427aed)
            }else{
                icon.image = .assets(.areas_icon_unSelected)
                selectedIcon.isHidden = true
                label.textColor = .custom(.gray_a2a7ae)
            }
        }
    }
    
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.areas_icon_unSelected)
    }
    
    private lazy var label = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_333333)
        $0.text = " "
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    
    private lazy var selectedIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.selected_tick)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(icon)
        contentView.addSubview(label)
        contentView.addSubview(selectedIcon)
        contentView.addSubview(line)
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(17.5.ztScaleValue).priority(.high)
            $0.height.width.equalTo(ZTScaleValue(16)).priority(.high)
            $0.bottom.equalToSuperview().offset(-10)
        }

        selectedIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-10.5.ztScaleValue)
            $0.width.height.equalTo(15.ztScaleValue)
        }
        
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(10.5)
            $0.right.equalTo(selectedIcon.snp.left).offset(-10.ztScaleValue)
        }
        
        line.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5.ztScaleValue)
        }
        
    }
    

    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

