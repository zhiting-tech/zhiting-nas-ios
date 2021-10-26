//
//  AddMemberSelectedCell.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/7.
//

import UIKit

class AddMemberSelectedCell: UITableViewCell, ReusableView {
    var member: User? {
        didSet {
            guard let member = member else { return }
            nicknameLabel.text = member.nickname
            readableBtn.isSelected = member.read == 1
            writableBtn.isSelected = member.write == 1
            deletableBtn.isSelected = member.deleted == 1
        }
    }

    private lazy var avatar = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.user_default)
        $0.layer.cornerRadius = 20.ztScaleValue
    }
    
    private lazy var nicknameLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.text = "user"
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var cancelBtn = Button().then {
        $0.setImage(.assets(.icon_close_blue), for: .normal)
    }

    private lazy var btnContainerView = UIView()

    lazy var readableBtn = OptionSelectBtn(title: "可读")
    lazy var writableBtn = OptionSelectBtn(title: "可写")
    lazy var deletableBtn = OptionSelectBtn(title: "可删")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        selectionStyle = .none
        contentView.addSubview(avatar)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(cancelBtn)
        contentView.addSubview(btnContainerView)
        btnContainerView.addSubview(readableBtn)
        btnContainerView.addSubview(writableBtn)
        btnContainerView.addSubview(deletableBtn)
    }
    
    private func setupConstraints() {
        avatar.snp.makeConstraints {
            $0.height.width.equalTo(40.ztScaleValue)
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.top)
            $0.left.equalTo(avatar.snp.right).offset(14.ztScaleValue)
            $0.right.equalToSuperview().offset(-40.ztScaleValue)
        }

        cancelBtn.snp.makeConstraints {
            $0.centerY.equalTo(avatar.snp.centerY)
            $0.height.width.equalTo(18.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.5.ztScaleValue)
        }
        
        btnContainerView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            $0.left.equalTo(avatar.snp.right).offset(14.ztScaleValue)
            $0.right.equalTo(cancelBtn.snp.left).offset(-40.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        readableBtn.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview()
        }
        
        writableBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        deletableBtn.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
        }



    }


}


extension AddMemberSelectedCell {
    class OptionSelectBtn: UIView {
        var selectCallback: ((_ isSelected: Bool) -> ())?

        var isSelected = false {
            didSet {
                if isSelected {
                    icon.image = .assets(.icon_selected_orange)
                    label.textColor = .custom(.black_333333)
                } else {
                    icon.image = .assets(.shareSelected_normal)
                    label.textColor = .custom(.gray_a2a7ae)
                }
            }
        }

        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.shareSelected_normal)
        }
        
        private lazy var label = UILabel().then {
            $0.font = .font(size: 12.ztScaleValue, type: .regular)
            $0.textColor = .custom(.gray_a2a7ae)
            
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(icon)
            addSubview(label)
            
            icon.snp.makeConstraints {
                $0.width.height.equalTo(16.ztScaleValue)
                $0.left.top.bottom.equalToSuperview()
            }
            
            label.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.left.equalTo(icon.snp.right).offset(5)
                $0.right.equalToSuperview()
            }

            isUserInteractionEnabled = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        }
        
        convenience init(title: String) {
            self.init(frame: .zero)
            label.text = title
        }
        

        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private func tap() {
            isSelected = !isSelected
            selectCallback?(isSelected)
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let biggerFrame = self.bounds.inset(by: UIEdgeInsets.init(top: -20, left: -20, bottom: -20, right: -20))
            return biggerFrame.contains(point)
            
            
        }

    }
    
    

}

