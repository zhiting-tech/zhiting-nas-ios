//
//  WarningCoverView.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/8/5.
//

import UIKit


class WarningCoverView: UIView {
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_warning)
    }
    
    private lazy var tipsLabel = UILabel().then {
        $0.text = " "
        $0.textColor = .custom(.orange_f6ae1e)
        $0.textAlignment = .center
        $0.font = .font(size: 12.ztScaleValue, type: .medium)
    }
    
    private lazy var btnStackView = UIStackView(arrangedSubviews: []).then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 15.ztScaleValue
        
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect = .zero, title: String = "", items: [Item]) {
        self.init(frame:frame)
        setupViews(title: title, items: items)
    }
    
    private func setupViews(title: String, items: [Item]) {
        tipsLabel.text = title

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurEffectView)
        addSubview(icon)
        addSubview(tipsLabel)
        addSubview(btnStackView)
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(23.ztScaleValue)
            $0.height.equalTo(40.ztScaleValue)
            $0.width.equalTo(35.ztScaleValue)
        }

        tipsLabel.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(6.5)
            $0.left.equalToSuperview().offset(-15)
            $0.right.equalToSuperview().offset(15)
        }
        
        btnStackView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(18.ztScaleValue)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(20.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-20.ztScaleValue)
        }
        
        items.map { item -> Button in
            let btn = Button()
            btn.clickCallBack = item.callback
            btn.setTitle(item.title, for: .normal)
            btn.backgroundColor = .custom(.blue_427aed)
            btn.layer.cornerRadius = 4
            btn.setTitleColor(.custom(.white_ffffff), for: .normal)
            btn.frame.size = CGSize(width: 60.ztScaleValue, height: 30.ztScaleValue)
            return btn
        }
        .forEach { btnStackView.addArrangedSubview($0) }

    }

    func set(title: String, items: [Item]) {
        tipsLabel.text = title

        btnStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        items.map { item -> Button in
            let btn = Button()
            btn.clickCallBack = item.callback
            btn.setTitle(item.title, for: .normal)
            btn.titleLabel?.font = .font(size: 12.ztScaleValue, type: .medium)
            btn.backgroundColor = .custom(.blue_427aed)
            btn.layer.cornerRadius = 4
            btn.setTitleColor(.custom(.white_ffffff), for: .normal)
            btn.frame.size = CGSize(width: 60.ztScaleValue, height: 30.ztScaleValue)
            return btn
        }
        .forEach { btnStackView.addArrangedSubview($0) }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension WarningCoverView {
    struct Item {
        let title: String
        var callback: ((Button) -> ())?
    }
}
