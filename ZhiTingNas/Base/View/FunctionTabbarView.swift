//
//  FunctionTabbarView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/19.
//

import UIKit

class FunctionTabbarView: UIView {
    
    lazy var shareBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.share_icon), for: .normal)
        $0.setImage(.assets(.share_icon), for: .highlighted)
        $0.setTitle("共享", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }
    lazy var downloadBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.download_icon), for: .normal)
        $0.setImage(.assets(.download_icon), for: .highlighted)
        $0.setTitle("下载", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }
    lazy var moveBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.move_icon), for: .normal)
        $0.setImage(.assets(.move_icon), for: .highlighted)
        $0.setTitle("移动到", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }
    lazy var copyBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.copy_icon), for: .normal)
        $0.setImage(.assets(.copy_icon), for: .highlighted)
        $0.setTitle("复制到", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }
    lazy var resetNameBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.resetName_icon), for: .normal)
        $0.setImage(.assets(.resetName_icon), for: .highlighted)
        $0.setTitle("重命名", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }
    lazy var deleteBtn = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(20), height: ZTScaleValue(20))
        $0.setImage(.assets(.delete_icon), for: .normal)
        $0.setImage(.assets(.delete_icon), for: .highlighted)
        $0.setTitle("删除", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(11), type: .bold)
        $0.imagePosition(style: .top, spacing: ZTScaleValue(5))
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
//        setConstrains()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setUpBtn()
    }
    
    private func setUpBtn(){
        let btns = [shareBtn,downloadBtn,moveBtn,copyBtn,resetNameBtn,deleteBtn]
        let btnWidth = Screen.screenWidth / CGFloat(btns.count)
        var offset: CGFloat = 0
        for (_,btn) in btns.enumerated() {
            self.addSubview(btn)
            btn.snp.makeConstraints({ (b) in
                b.width.equalTo(btnWidth)
                b.height.equalToSuperview().multipliedBy(ZTScaleValue(0.8))
                b.left.equalToSuperview().offset(offset)
                b.top.equalToSuperview()
            })
            offset += btnWidth
        }

    }
    
    public func setResetNameBtnIsEnabled(isEnabled:Bool){
        if isEnabled {
            resetNameBtn.isUserInteractionEnabled = true
            resetNameBtn.setImage(.assets(.resetName_icon), for: .normal)
            resetNameBtn.setImage(.assets(.resetName_icon), for: .highlighted)
            resetNameBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{
            resetNameBtn.isUserInteractionEnabled = false
            resetNameBtn.setImage(.assets(.resetName_not_icon), for: .normal)
            resetNameBtn.setImage(.assets(.resetName_not_icon), for: .highlighted)
            resetNameBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }
    
    public func setShareBtnIsEnabled(isEnabled:Bool){
        if isEnabled {//允许点击共享按钮
            shareBtn.isUserInteractionEnabled = true
            shareBtn.setImage(.assets(.share_icon), for: .normal)
            shareBtn.setImage(.assets(.share_icon), for: .highlighted)
            shareBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{//不允许点击共享按钮
            shareBtn.isUserInteractionEnabled = false
            shareBtn.setImage(.assets(.share_not_icon), for: .normal)
            shareBtn.setImage(.assets(.share_not_icon), for: .highlighted)
            shareBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }
    
    public func setDeleteBtnIsEnabled(isEnabled:Bool){
        if isEnabled {//允许点击删除按钮
            deleteBtn.isUserInteractionEnabled = true
            deleteBtn.setImage(.assets(.delete_icon), for: .normal)
            deleteBtn.setImage(.assets(.delete_icon), for: .highlighted)
            deleteBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{//不允许点击删除按钮
            deleteBtn.isUserInteractionEnabled = false
            deleteBtn.setImage(.assets(.delete_not_icon), for: .normal)
            deleteBtn.setImage(.assets(.delete_not_icon), for: .highlighted)
            deleteBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }
    
    public func setMoveBtnIsEnabled(isEnabled:Bool){
        if isEnabled {//允许点击移动按钮
            moveBtn.isUserInteractionEnabled = true
            moveBtn.setImage(.assets(.move_icon), for: .normal)
            moveBtn.setImage(.assets(.move_icon), for: .highlighted)
            moveBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{//不允许点击移动按钮
            moveBtn.isUserInteractionEnabled = false
            moveBtn.setImage(.assets(.move_not_icon), for: .normal)
            moveBtn.setImage(.assets(.move_not_icon), for: .highlighted)
            moveBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }

    public func setCopyBtnIsEnabled(isEnabled:Bool){
        if isEnabled {//允许点击移动按钮
            copyBtn.isUserInteractionEnabled = true
            copyBtn.setImage(.assets(.copy_icon), for: .normal)
            copyBtn.setImage(.assets(.copy_icon), for: .highlighted)
            copyBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{//不允许点击移动按钮
            copyBtn.isUserInteractionEnabled = false
            copyBtn.setImage(.assets(.copy_not_icon), for: .normal)
            copyBtn.setImage(.assets(.copy_not_icon), for: .highlighted)
            copyBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }

    public func setDownloadBtnIsEnabled(isEnabled:Bool){
        if isEnabled {//允许点击下载按钮
            downloadBtn.isUserInteractionEnabled = true
            downloadBtn.setImage(.assets(.download_icon), for: .normal)
            downloadBtn.setImage(.assets(.download_icon), for: .highlighted)
            downloadBtn.setTitleColor(.custom(.white_ffffff), for: .normal)
        }else{//不允许点击下载按钮
            downloadBtn.isUserInteractionEnabled = false
            downloadBtn.setImage(.assets(.download_not_icon), for: .normal)
            downloadBtn.setImage(.assets(.download_not_icon), for: .highlighted)
            downloadBtn.setTitleColor(.custom(.blue_7ba2f2), for: .normal)
        }
    }


    
}
