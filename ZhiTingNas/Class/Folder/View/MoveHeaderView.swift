//
//  MoveHeaderView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/27.
//

import UIKit

class MoveHeaderView: UIView {
    /**
     
        0:返回上级目录
        1:取消移动或者复制操作
     */
    var actionCallback: ((_ actionTag: Int) -> ())?

    
    lazy var backBtn = UILabel().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(18), type: .bold)

    }
    
    lazy var cancleBtn = Button().then {
        $0.setTitle("取消", for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback!(1)
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
    
    convenience init(tye: MoveType, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        switch tye {
        case .move:
            backBtn.text = "移动到"
//            backBtn.setImage(.assets(.navigation_back), for: .normal)
        case .copy:
            backBtn.text = "复制到"
//            backBtn.setImage(.assets(.navigation_back), for: .normal)
        }
    }
    
    private func setupViews(){
        addSubview(backBtn)
        addSubview(cancleBtn)
    }

    private func setupConstraints(){
        backBtn.snp.makeConstraints {
            $0.bottom.equalTo(-ZTScaleValue(10))
            $0.left.equalTo(ZTScaleValue(10))
            $0.width.equalTo(ZTScaleValue(80))
            $0.height.equalTo(20)
        }
        
        cancleBtn.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalTo(ZTScaleValue(15))
        }
    }
}
