//
//  CustomHeaderView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/17.
//

import UIKit

class CustomHeaderView: UIView {

    enum BtnTypes {
        case transfer
        case newFolder
        case upload
    }

    var switchAreaCallButtonCallback: (() -> ())?
    
    
    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(24.0), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "选择家庭"
        $0.lineBreakMode = .byTruncatingTail
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_down)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    lazy var rightView = UIView().then {
        $0.isUserInteractionEnabled = true
    }

    lazy var transferListBtn = Button().then {
        $0.setImage(.assets(.transferList_icon), for: .normal)
    }
    
    lazy var newFolderBtn = Button().then {
        $0.setImage(.assets(.newFolder_icon), for: .normal)
    }
    
    lazy var uploadBtn = Button().then {
        $0.setImage(.assets(.upload_icon), for: .normal)
        
    }
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(titleLabel)
        addSubview(arrow)
        addSubview(rightView)

    }
    
    private func setConstrains() {
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-5)
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.lessThanOrEqualTo(rightView.snp.left).offset(-44)
        }
        
        arrow.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY).offset(2)
            $0.height.equalTo(13.5)
            $0.width.equalTo(8)
            $0.left.equalTo(titleLabel.snp.right).offset(14)
        }
        
        rightView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-19.5).priority(.high)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(32)
            $0.width.equalTo(0)
        }

    }
    
    @objc private func tap() {
        switchAreaCallButtonCallback?()
    }
    
    
    func setBtns(btns: [BtnTypes]) {
        rightView.subviews.forEach { $0.removeFromSuperview() }
        var marginX: CGFloat = 0

        btns.forEach { btnType in
            switch btnType {
            case .transfer:
                rightView.addSubview(transferListBtn)
                transferListBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(32)
                    $0.top.equalToSuperview()
                }
            case .newFolder:
                rightView.addSubview(newFolderBtn)
                newFolderBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(32)
                    $0.top.equalToSuperview()
                }
            case .upload:
                rightView.addSubview(uploadBtn)
                uploadBtn.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview().offset(-marginX)
                    $0.width.height.equalTo(32)
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
