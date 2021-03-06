//
//  StatusCoverView.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/8/5.
//

import UIKit


class StatusCoverView: UIView {
    var btnCallback: ((_ index: Int) -> ())?

    private lazy var bgView = UIView()
    
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 0.9
        return blurView
    }()

    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_warning)
    }
    
    private lazy var tipsLabel = UILabel().then {
        $0.text = " "
        $0.textColor = .custom(.orange_f6ae1e)
        $0.textAlignment = .center
        $0.font = .font(size: 12.ztScaleValue, type: .medium)
        $0.lineBreakMode = .byTruncatingMiddle
    }
    
    private lazy var statusTag = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    
    private lazy var btnStackView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
    }
    
    private func setupViews() {
        addSubview(blurView)
        addSubview(bgView)
        bgView.addSubview(icon)
        bgView.addSubview(tipsLabel)
        bgView.addSubview(btnStackView)
        bgView.addSubview(statusTag)
    }
    
    private func setupConstraints() {
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(23.ztScaleValue)
            $0.height.equalTo(40.ztScaleValue)
            $0.width.equalTo(35.ztScaleValue)
        }
        
        statusTag.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.ztScaleValue)
            $0.right.equalToSuperview().offset(-10.ztScaleValue)
            $0.height.equalTo(20.ztScaleValue)
            $0.width.equalTo(60.ztScaleValue)
        }

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(6.5)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        btnStackView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview().offset(15.ztScaleValue).priority(.high)
            $0.right.lessThanOrEqualToSuperview().offset(-15.ztScaleValue).priority(.high)
        }
    }
    
    /// ?????????????????????
    func setStatus(_ folder: FolderModel) {
        switch folder.statusEnum {
        case .deleting:
            setTagStyle(tagImage: .assets(.icon_deleting))
        case .failToDelete:
            tipsLabel.text = "???????????????(\(folder.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "???????????????(\(folder.name.prefix(2))...)??????"
            }
            setBtnStyle(items: ["??????"])
        case .failToEdit:
            tipsLabel.text = "???????????????(\(folder.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "???????????????(\(folder.name.prefix(2))...)??????"
            }
            setBtnStyle(items: ["??????"])
        case .editing:
            setTagStyle(tagImage: .assets(.icon_editing))
        case .none:
            break
        }
    }
    
    /// ????????????????????????
    func setStatus(_ lv: LogicVolume) {
        switch lv.statusEnum {
        case .none:
            self.removeFromSuperview()
        case .failToDelete:
            tipsLabel.text = "????????????(\(lv.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "????????????(\(lv.name.prefix(2))...)??????"
            }

            setBtnStyle(items: ["??????"])
        case .deleting:
            setTagStyle(tagImage: .assets(.icon_deleting))
        case .failToAdd:
            tipsLabel.text = "????????????(\(lv.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "????????????(\(lv.name.prefix(2))...)??????"
            }
            setBtnStyle(items: ["??????", "????????????"])
        case .adding:
            setTagStyle(tagImage: .assets(.icon_adding))
        case .failToEdit:
            tipsLabel.text = "????????????(\(lv.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "????????????(\(lv.name.prefix(2))...)??????"
            }
            setBtnStyle(items: ["??????", "????????????"])
        case .editing:
            setTagStyle(tagImage: .assets(.icon_editing))
        }
    }
    
    /// ?????????????????????
    func setStatus(_ storagePool: StoragePoolModel) {
        switch storagePool.statusEnum {
        case .none:
            self.removeFromSuperview()
        case .failToDelete:
            tipsLabel.text = "???????????????(\(storagePool.name))??????"
            if tipsLabel.isTruncated {
                tipsLabel.text = "???????????????(\(storagePool.name.prefix(2))...)??????"
            }
            setBtnStyle(items: ["??????"])
        case .deleting:
            setTagStyle(tagImage: .assets(.icon_deleting))
        }
    }

    /// ???????????????????????????
    /// - Parameter tagImage: ???????????????
    private func setTagStyle(tagImage: UIImage?) {
        btnStackView.isHidden = true
        tipsLabel.isHidden = true
        blurView.isHidden = true
        icon.isHidden = true
        statusTag.isHidden = false
        statusTag.image = tagImage
    }
    
    
    /// ???????????????????????????????????????
    /// - Parameters:
    ///   - title: ????????????
    ///   - items: ??????
    private func setBtnStyle(items: [String]) {
        btnStackView.isHidden = false
        tipsLabel.isHidden = false
        blurView.isHidden = false
        icon.isHidden = false
        statusTag.isHidden = true

        
        
        btnStackView.subviews.forEach { $0.removeFromSuperview() }

        var i = 0
        let btns = items.map { item -> Button in
            let btn = Button()
            btn.setTitle(item, for: .normal)
            btn.titleLabel?.font = .font(size: 12.ztScaleValue, type: .medium)
            btn.backgroundColor = .custom(.blue_427aed)
            btn.layer.cornerRadius = 4
            btn.setTitleColor(.custom(.white_ffffff), for: .normal)
            btn.frame.size = CGSize(width: 60.ztScaleValue, height: 30.ztScaleValue)
            btn.tag = i
            btn.clickCallBack = { [weak self] btn in
                self?.btnCallback?(btn.tag)
                
            }
            i += 1
            return btn
        }
        
        if btns.count == 1 {
            btnStackView.addSubview(btns[0])
            btns[0].snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.edges.equalToSuperview()
                $0.height.equalTo(30.ztScaleValue)
                $0.width.equalTo(60.ztScaleValue)
            }

        } else {
            var lastBtn = Button()
            for (index, btn) in btns.enumerated() {
                btnStackView.addSubview(btn)
                if index == 0 {
                    btn.snp.makeConstraints {
                        $0.left.equalToSuperview()
                        $0.height.equalTo(30.ztScaleValue)
                        $0.width.equalTo(60.ztScaleValue)
                        $0.top.bottom.equalToSuperview()
                    }
                    
                } else if index == btns.count - 1 {
                    btn.snp.makeConstraints {
                        $0.left.equalTo(lastBtn.snp.right).offset(15.ztScaleValue)
                        $0.height.equalTo(30.ztScaleValue)
                        $0.width.equalTo(60.ztScaleValue)
                        $0.right.equalToSuperview()
                    }
                    
                } else {
                    btn.snp.makeConstraints {
                        $0.right.equalToSuperview()
                        $0.height.equalTo(30.ztScaleValue)
                        $0.width.equalTo(60.ztScaleValue)
                        $0.left.equalTo(lastBtn.snp.right).offset(15.ztScaleValue)
                    }
                    
                }
                
                lastBtn = btn
                
            }
        }

        

    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

