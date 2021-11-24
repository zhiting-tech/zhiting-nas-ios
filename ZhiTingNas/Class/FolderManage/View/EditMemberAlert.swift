//
//  EditMemberAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/5.
//

import UIKit

class EditMemberAlert: UIView {

    var sureCallback: ((_ read: Bool, _ write: Bool, _ delete: Bool) -> ())?

    private lazy var bgView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private lazy var closeBtn = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private lazy var membersIconView = MemberHeader()

    
    lazy var readBtn = EditMemberAuthBtn(type: .read)
    lazy var writeBtn = EditMemberAuthBtn(type: .write)
    lazy var deleteBtn = EditMemberAuthBtn(type: .delete)

    private lazy var tipsLabel = UILabel().then {
        $0.textColor = .custom(.gray_a2a7ae)
        $0.numberOfLines = 0
        let text = "注:\n1、勾选代表有权限。\n2、必须有读的权限才能写和删除的权限。\n3、“读”：查看该文件夹下所有文件/文件夹的权限。\n4、“写”：包括新建文件夹、上传、重命名、共享、下载的权限。\n5、“删”：包括移动、删除的权限。"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        

        let attributedText = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font : UIFont.font(size: 12.ztScaleValue, type: .regular),
            NSAttributedString.Key.foregroundColor : UIColor.custom(.gray_a2a7ae),
            NSAttributedString.Key.paragraphStyle : paragraph
            
        ])
        
        $0.attributedText = attributedText
    }
    
    lazy var sureBtn = UIButton().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.setTitle("确定", for: .normal)
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = 10
    }


}

extension EditMemberAlert {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()

    }
    
    private func setupViews() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(closeBtn)
        containerView.addSubview(membersIconView)
        containerView.addSubview(readBtn)
        containerView.addSubview(writeBtn)
        containerView.addSubview(deleteBtn)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(sureBtn)
        
        sureBtn.addTarget(self, action: #selector(tapSure), for: .touchUpInside)
        
        readBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if !btn.isSelected {
                self.writeBtn.isSelected = false
                self.deleteBtn.isSelected = false
            }
        }
        
        writeBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if btn.isSelected && !self.readBtn.isSelected {
                self.readBtn.isSelected = true
            }
        }
        
        deleteBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if btn.isSelected && !self.readBtn.isSelected {
                self.readBtn.isSelected = true
            }
        }

    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30.ztScaleValue)
        }
        
        closeBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-18.ztScaleValue)
            $0.height.width.equalTo(10.ztScaleValue)
        }
        
        membersIconView.snp.makeConstraints {
            $0.top.equalTo(closeBtn.snp.bottom).offset(10.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)

        }
        
        let btnW = (Screen.screenWidth - 30.ztScaleValue - 4 * 15.ztScaleValue) / 3
        let btnH = 60.ztScaleValue
        
        readBtn.snp.makeConstraints {
            $0.top.equalTo(membersIconView.snp.bottom).offset(20.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.height.equalTo(btnH)
            $0.width.equalTo(btnW)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.top.equalTo(membersIconView.snp.bottom).offset(20.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(btnH)
            $0.width.equalTo(btnW)
        }
        
        writeBtn.snp.makeConstraints {
            $0.top.equalTo(membersIconView.snp.bottom).offset(20.ztScaleValue)
            $0.left.equalTo(readBtn.snp.right).offset(15.ztScaleValue)
            $0.height.equalTo(btnH)
            $0.width.equalTo(btnW)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(readBtn.snp.bottom).offset(30.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }

        sureBtn.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(30.ztScaleValue)
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
        }

    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 1
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    @objc private func close() {
        removeFromSuperview()
    }
    
    @objc func tapSure() {
            sureCallback?(readBtn.isSelected, writeBtn.isSelected, deleteBtn.isSelected)
    }

    func set(members: [User]) {
        membersIconView.setupViews(members: members)
    }
    
    func set(member: User, read: Bool = false, write: Bool = false, delete: Bool = false) {
        membersIconView.setupViews(members: [member])
        readBtn.isSelected = read
        writeBtn.isSelected = write
        deleteBtn.isSelected = delete

    }
}

// MARK: - EditMemberAuthBtn
extension EditMemberAlert {
    class EditMemberAuthBtn: UIView {
        enum BtnType {
            case read
            case write
            case delete
        }
        
        var type: BtnType = .read
        
        var clickCallback: ((EditMemberAuthBtn) -> ())?

        var isSelected = false {
            didSet {
                if isSelected {
                    layer.borderColor = UIColor.custom(.orange_ff6d57).cgColor
                    titleLabel.textColor = .custom(.orange_ff6d57)
                    selectedIcon.isHidden = false
                    switch type {
                    case .read:
                        icon.image = .assets(.icon_readable_selected)
                    case .write:
                        icon.image = .assets(.icon_writable_selected)
                    case .delete:
                        icon.image = .assets(.icon_deletable_selected)
                    }

                } else {
                    layer.borderColor = UIColor.custom(.gray_a2a7ae).cgColor
                    titleLabel.textColor = .custom(.gray_a2a7ae)
                    selectedIcon.isHidden = true
                    switch type {
                    case .read:
                        icon.image = .assets(.icon_readable_unselected)
                    case .write:
                        icon.image = .assets(.icon_writable_unselected)
                    case .delete:
                        icon.image = .assets(.icon_deletable_unselected)
                    }
                }
            }
        }

        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        
        private lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 14.ztScaleValue, type: .bold)
            $0.textAlignment = .center
            $0.textColor = .custom(.gray_a2a7ae)
        }
        
        private lazy var selectedIcon = ImageView().then {
            $0.contentMode = .scaleToFill
            $0.image = .assets(.icon_auth_selected)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(icon)
            addSubview(titleLabel)
            addSubview(selectedIcon)
            layer.cornerRadius = 4.ztScaleValue
            clipsToBounds = true
            layer.borderColor = UIColor.custom(.gray_a2a7ae).cgColor
            layer.borderWidth = 1
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            isUserInteractionEnabled = true
            selectedIcon.isHidden = true
            
            selectedIcon.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.width.equalTo(18)
            }
            
            icon.snp.makeConstraints {
                $0.height.width.equalTo(15.ztScaleValue)
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(11.5.ztScaleValue)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(icon.snp.bottom).offset(5)
                $0.centerX.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        convenience init(type: BtnType) {
            self.init(frame: .zero)
            self.type = type
            
            switch type {
            case .read:
                titleLabel.text = "可读"
                icon.image = .assets(.icon_readable_unselected)
            case .write:
                titleLabel.text = "可写"
                icon.image = .assets(.icon_writable_unselected)
            case .delete:
                titleLabel.text = "可删"
                icon.image = .assets(.icon_deletable_unselected)
            }

        }
        
        @objc
        private func tap() {
            clickCallback?(self)
        }

        
    }

}

extension EditMemberAlert {
    class MemberHeader: UIView {
        var titleLabel = UILabel().then {
            $0.font = .font(size: 14.ztScaleValue, type: .bold)
            $0.textColor = .custom(.black_3f4663)
        }
        
        private override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        convenience init(frame: CGRect, members: [User] = []) {
            self.init(frame: frame)
            setupViews(members: members)
        }
        
        func setupViews(members: [User]) {
            subviews.forEach { $0.removeFromSuperview() }

            if members.count > 1 {
                titleLabel.textAlignment = .left
                titleLabel.text = "\(members.first?.nickname ?? "")等\(members.count)人"
                var currentWidth: CGFloat = 0
                
                let maxWidth: CGFloat = Screen.screenWidth - 60.ztScaleValue
                
                for _ in members {
                    if currentWidth < maxWidth {
                        let icon = ImageView()
                        icon.contentMode = .scaleToFill
                        icon.image = .assets(.user_default)
                        icon.layer.cornerRadius = 30.ztScaleValue
                        icon.layer.borderWidth = 2
                        icon.layer.borderColor = UIColor.custom(.white_ffffff).cgColor
                        addSubview(icon)
                        
                        
                        icon.snp.makeConstraints {
                            $0.left.equalToSuperview().offset(currentWidth)
                            $0.width.height.equalTo(60.ztScaleValue)
                            $0.top.equalToSuperview()
                        }
                        
                        currentWidth += 45.ztScaleValue
                        if currentWidth >= maxWidth {
                            icon.backgroundColor = .custom(.gray_eeeeee)
                            icon.contentMode = .center
                            icon.image = .assets(.icon_more)
                            break
                        }
                    }
                    
                    
                }
                
                addSubview(titleLabel)
                titleLabel.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(70.ztScaleValue)
                    $0.left.equalToSuperview()
                    $0.bottom.equalToSuperview()
                }
                


            } else {
                titleLabel.textAlignment = .center
                titleLabel.text = members.first?.nickname ?? ""
                let icon = ImageView()
                icon.contentMode = .scaleToFill
                icon.image = .assets(.user_default)
                icon.layer.cornerRadius = 30.ztScaleValue
                icon.layer.borderWidth = 2
                icon.layer.borderColor = UIColor.custom(.white_ffffff).cgColor
                
                addSubview(titleLabel)
                addSubview(icon)

                icon.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.top.equalToSuperview()
                    $0.width.height.equalTo(60.ztScaleValue)
                }
                
                titleLabel.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.top.equalTo(icon.snp.bottom).offset(10)
                    $0.bottom.equalToSuperview()
                }
            }
            
            

        }

    }
    

}


class EditShareMemberAlert: EditMemberAlert {
    
    override func tapSure() {
        if readBtn.isSelected {
            sureCallback?(readBtn.isSelected, writeBtn.isSelected, deleteBtn.isSelected)
        }
    }
    
    public func reSetBtn(){
        readBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if !btn.isSelected {
                self.writeBtn.isSelected = false
                self.deleteBtn.isSelected = false
                self.sureBtn.alpha = 0.5
                self.sureBtn.isUserInteractionEnabled = false
            }else{
                self.sureBtn.alpha = 1
                self.sureBtn.isUserInteractionEnabled = true
            }
        }
        
        writeBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if btn.isSelected && !self.readBtn.isSelected {
                self.readBtn.isSelected = true
                self.sureBtn.alpha = 1
                self.sureBtn.isUserInteractionEnabled = true
            }
        }
        
        deleteBtn.clickCallback = { [weak self] btn in
            guard let self = self else { return }
            btn.isSelected = !btn.isSelected
            if btn.isSelected && !self.readBtn.isSelected {
                self.readBtn.isSelected = true
                self.sureBtn.alpha = 1
                self.sureBtn.isUserInteractionEnabled = true
            }
        }

    }
    
}
