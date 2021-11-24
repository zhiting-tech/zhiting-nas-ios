//
//  FolderDetailHeader.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/28.
//

import UIKit

class FolderDetailHeader: UIView {
    
    enum BtnTypes {
        case transfer
        case newFolder
        case upload
    }
    /**
     
        0:返回上级目录
        1:取消移动或者复制操作
     */
    var actionCallback: ((_ actionTag: Int) -> ())?

    
    lazy var backBtn = Button().then {
        $0.setImage(.assets(.navigation_back), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(0)
        }
    }
    
    lazy var fileNameLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(18), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .left
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    lazy var rightView = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    
    lazy var transferListBtn = Button().then {
        $0.setImage(.assets(.transferList_icon), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(1)
        }
    }

    lazy var newFolderBtn = Button().then {
        $0.setImage(.assets(.newFolder_icon), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(2)
        }
    }
    
    lazy var uploadBtn = Button().then {
        $0.setImage(.assets(.upload_icon), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(3)
        }
    }


    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(currentFileName: String, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        fileNameLabel.text = currentFileName
    }
    
    private func setupViews(){
        addSubview(backBtn)
        addSubview(fileNameLabel)
        addSubview(rightView)

    }

    private func setupConstraints(){
        backBtn.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(10))
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(8))
            $0.height.equalTo(14)
        }
        
        fileNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.left.equalTo(backBtn.snp.right).offset(ZTScaleValue(10))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
            $0.right.equalTo(rightView.snp.left).offset(ZTScaleValue(-15))
        }
        
        rightView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-19.5).priority(.high)
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10))
            $0.height.equalTo(24)
            $0.width.equalTo(0)
        }

    }
    
    @objc private func dismiss() {
        self.actionCallback!(0)
    }

        
     public func setBtns(btns: [BtnTypes]) {
            rightView.subviews.forEach { $0.removeFromSuperview() }
            var marginX: CGFloat = 0

            btns.forEach { btnType in
                switch btnType {
                case .transfer:
                    rightView.addSubview(transferListBtn)
                    transferListBtn.snp.remakeConstraints {
                        $0.bottom.equalToSuperview()
                        $0.right.equalToSuperview().offset(-marginX)
                        $0.width.height.equalTo(24)
                        $0.top.equalToSuperview()
                    }
                case .newFolder:
                    rightView.addSubview(newFolderBtn)
                    newFolderBtn.snp.remakeConstraints {
                        $0.bottom.equalToSuperview()
                        $0.right.equalToSuperview().offset(-marginX)
                        $0.width.height.equalTo(24)
                        $0.top.equalToSuperview()
                    }
                case .upload:
                    rightView.addSubview(uploadBtn)
                    uploadBtn.snp.remakeConstraints {
                        $0.bottom.equalToSuperview()
                        $0.right.equalToSuperview().offset(-marginX)
                        $0.width.height.equalTo(24)
                        $0.top.equalToSuperview()
                    }
                }
                marginX += 49
                
            }
            
            rightView.snp.updateConstraints {
                $0.width.equalTo(marginX)
            }
        }
        
    }
