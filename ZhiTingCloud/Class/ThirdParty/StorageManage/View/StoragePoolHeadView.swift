//
//  StoragePoolHeadView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/6/30.
//

import UIKit

class StoragePoolHeadView: UIView {
    /**
     
        0:返回上级目录
        1:删除
        2:重命名
        3:硬盘数量
     */
    var actionCallback: ((_ actionTag: Int) -> ())?
    var currentModel = StoragePoolModel()

    // MARK: - navigationView
    lazy var navigationView = UIView().then {
        $0.backgroundColor = .custom(.blue_427aed)
    }
    
    lazy var backBtn = Button().then {
        $0.setImage(.assets(.back_white), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(0)
        }
    }
    
    lazy var backLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(18), type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.text = "存储池"
        $0.textAlignment = .left
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    lazy var deletedBtn = Button().then {
        $0.setTitle("删除", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback!(1)
        }
    }
    
    // MARK: - storagePoolInfoView
    lazy var storagePoolInfoView = UIView().then {
        $0.backgroundColor = .custom(.blue_427aed)
    }
    
    //存储池图标
    lazy var storagePoolImgView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_storagePool)
    }
    //存储池名称
    lazy var storagePoolNameLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(20), type: .bold)
        $0.textColor = .custom(.white_ffffff)
        $0.text = "存储池"
        $0.textAlignment = .left
    }
    //重命名按钮
    lazy var resetNameBtn = Button().then {
        $0.setImage(.assets(.storagePool_resetName), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback!(2)
        }
    }
    //物理硬盘数量
    lazy var HardDiskCountLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.textColor = .custom(.white_ffffff)
        $0.text = "物理硬盘:0个"
        $0.textAlignment = .left
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hardDiskCountClick)))
    }
    //可分容量
    lazy var AllocableMemoryLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .left
        $0.text = "400GB 可分配容量"
    }
    //总容量
    lazy var AllMemoryLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.textColor = .custom(.white_ffffff)
        $0.textAlignment = .right
        $0.text = "1000GB 总容量"
    }
    
    lazy var allProgressView = UIView().then{
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
    }
    
    lazy var allocableProgressView = UIView().then {
        $0.backgroundColor = .custom(.green_01dbc0)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
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
    
    convenience init(model: StoragePoolModel, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: .zero))
        
    }
    
    public func setModel(model:StoragePoolModel){
        storagePoolNameLabel.text = model.name
        if model.name == "__system__" {
            deletedBtn.isHidden = true
            resetNameBtn.isHidden = true
            HardDiskCountLabel.text = String(format: "物理硬盘: %d个", model.pv.count)
            HardDiskCountLabel.isUserInteractionEnabled = false
        }else{
            deletedBtn.isHidden = false
            resetNameBtn.isHidden = false
            HardDiskCountLabel.text = String(format: "物理硬盘: %d个 >", model.pv.count)
            HardDiskCountLabel.isUserInteractionEnabled = true
        }

        let canUseCapacity = model.capacity - model.use_capacity
        AllocableMemoryLabel.text = ZTCTool.convertFileSize(size: canUseCapacity) + "可分容量"
        AllMemoryLabel.text = ZTCTool.convertFileSize(size: model.capacity) + "总容量"
        
        allocableProgressView.snp.remakeConstraints {
            $0.left.top.height.equalTo(allProgressView)
            $0.width.equalTo(allProgressView).multipliedBy(CGFloat(model.use_capacity)/CGFloat(model.capacity))
        }
    }
    
    private func setupViews(){
        addSubview(navigationView)
        navigationView.addSubview(backBtn)
        navigationView.addSubview(backLabel)
        navigationView.addSubview(deletedBtn)
        
        addSubview(storagePoolInfoView)
        storagePoolInfoView.addSubview(storagePoolImgView)
        storagePoolInfoView.addSubview(storagePoolNameLabel)
        storagePoolInfoView.addSubview(resetNameBtn)
        storagePoolInfoView.addSubview(HardDiskCountLabel)
        storagePoolInfoView.addSubview(AllocableMemoryLabel)
        storagePoolInfoView.addSubview(AllMemoryLabel)
        storagePoolInfoView.addSubview(allProgressView)
        storagePoolInfoView.addSubview(allocableProgressView)

    }

    private func setupConstraints(){
        
        navigationView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height)
        }
        
        backBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10))
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(7.5))
            $0.height.equalTo(15)
        }
        
        backLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10))
            $0.left.equalTo(backBtn.snp.right).offset(ZTScaleValue(11))
            $0.width.equalTo(ZTScaleValue(100))
            $0.height.equalTo(20)
        }
        
        deletedBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(10))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalTo(20)
        }
        
         /*        storagePoolInfoView             **/
        
        storagePoolInfoView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(270) - Screen.k_nav_height)
        }
        
        storagePoolImgView.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(30))
            $0.left.equalTo(ZTScaleValue(26))
            $0.width.equalTo(ZTScaleValue(51))
            $0.height.equalTo(ZTScaleValue(55))
        }
        
        storagePoolNameLabel.snp.makeConstraints {
            $0.bottom.equalTo(storagePoolImgView.snp.centerY).offset(-ZTScaleValue(5))
            $0.left.equalTo(storagePoolImgView.snp.right).offset(ZTScaleValue(21))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
            $0.height.equalTo(ZTScaleValue(19))
        }
        
        resetNameBtn.snp.makeConstraints {
            $0.centerY.equalTo(storagePoolNameLabel)
            $0.left.equalTo(storagePoolNameLabel.snp.right).offset(ZTScaleValue(20))
            $0.width.height.equalTo(ZTScaleValue(15))
        }

        HardDiskCountLabel.snp.makeConstraints {
            $0.top.equalTo(storagePoolImgView.snp.centerY).offset(ZTScaleValue(5))
            $0.left.equalTo(storagePoolImgView.snp.right).offset(ZTScaleValue(21))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
            $0.height.equalTo(ZTScaleValue(13.5))
        }

        AllMemoryLabel.snp.makeConstraints {
            $0.top.equalTo(storagePoolImgView.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalTo(ZTScaleValue(25))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
            $0.height.equalTo(ZTScaleValue(11.5))
        }

        AllocableMemoryLabel.snp.makeConstraints {
            $0.top.equalTo(AllMemoryLabel)
            $0.right.equalTo(-ZTScaleValue(25))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
            $0.height.equalTo(ZTScaleValue(11.5))
        }

        allProgressView.snp.makeConstraints {
            $0.top.equalTo(AllMemoryLabel.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalTo(AllMemoryLabel.snp.left)
            $0.right.equalTo(AllocableMemoryLabel.snp.right)
            $0.height.equalTo(ZTScaleValue(8))
        }
        
        let width = 0
        
        allocableProgressView.snp.makeConstraints {
            $0.left.top.height.equalTo(allProgressView)
            $0.width.equalTo(width)
        }

    }
    

}

extension StoragePoolHeadView {
    
    @objc private func dismiss() {
        self.actionCallback!(0)
    }
    
    @objc private func hardDiskCountClick(){
        self.actionCallback!(3)
    }

}
