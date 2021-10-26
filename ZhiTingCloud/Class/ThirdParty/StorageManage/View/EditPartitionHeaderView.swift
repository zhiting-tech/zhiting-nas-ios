//
//  EditPartitionHeaderView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/7/5.
//

import UIKit

class EditPartitionHeaderView: UIView {

    /**
        0:返回上级目录
        1:删除
     */
    var actionCallback: ((_ actionTag: Int) -> ())?

    // MARK: - navigationView
    lazy var navigationView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    lazy var backBtn = Button().then {
        $0.setImage(.assets(.navigation_back), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(0)
        }
    }
    
    lazy var backLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(18), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "存储池"
        $0.textAlignment = .left
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    lazy var deletedBtn = Button().then {
        $0.setTitle("删除", for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
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
    
    convenience init(type: PartitionType, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: .zero))
        
        if type == .add {
            backLabel.text = "添加分区"
            deletedBtn.isHidden = true
        }else{
            backLabel.text = "编辑分区"
            deletedBtn.isHidden = false
        }
    }
    
    private func setupViews(){
        addSubview(navigationView)
        navigationView.addSubview(backBtn)
        navigationView.addSubview(backLabel)
        navigationView.addSubview(deletedBtn)
    }

    private func setupConstraints(){
        
        navigationView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height)
        }
        
        backBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(15))
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(7.5))
            $0.height.equalTo(13.5)
        }
        
        backLabel.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.left.equalTo(backBtn.snp.right).offset(ZTScaleValue(11))
            $0.width.equalTo(ZTScaleValue(100))
            $0.height.equalTo(20)
        }
        
        deletedBtn.snp.makeConstraints {
            $0.bottom.equalTo(backLabel)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalTo(13)
        }
        
    }


}


extension EditPartitionHeaderView {
    
    @objc private func dismiss() {
        self.actionCallback!(0)
    }

}
