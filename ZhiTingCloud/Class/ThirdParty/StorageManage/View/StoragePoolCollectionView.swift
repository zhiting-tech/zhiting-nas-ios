//
//  StoragePoolCollectionView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/7/1.
//

import UIKit

class StoragePoolCollectionView: UIView {

    /**
        1:添加分区
        2:点击Cell
     */
    var actionCallback: ((_ actionTag: Int, _ index: Int ) -> ())?
    
    
    lazy var coverView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(20)
    }
        
    lazy var titleLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "存储池分区"
        $0.textAlignment = .left
    }
    lazy var addBtn = Button().then {
        $0.setImage(.assets(.storage_add), for: .normal)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.actionCallback?(1,0)
        }
    }
    
    var currentModel = StoragePoolModel()
    
    //存储池列表
    
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.itemSize = CGSize(width: ZTScaleValue(165), height:  ZTScaleValue(160))
        //行列间距
        $0.minimumLineSpacing = ZTScaleValue(5)
        $0.minimumInteritemSpacing = ZTScaleValue(15)
        $0.sectionInset = UIEdgeInsets(top: 0, left: ZTScaleValue(15), bottom: 0, right: ZTScaleValue(15))

    }
    lazy var storagePoolCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.isUserInteractionEnabled = true
        $0.register(StoragePoolPartitionCell.self, forCellWithReuseIdentifier: StoragePoolPartitionCell.reusableIdentifier)
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
        self.currentModel = model
        addBtn.isHidden = (model.name == "__system__")
        self.storagePoolCollectionView.reloadData()
    }
    
    private func setupViews(){
        addSubview(coverView)
        coverView.addSubview(titleLabel)
        coverView.addSubview(addBtn)
        coverView.addSubview(storagePoolCollectionView)
        
    }

    private func setupConstraints(){
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(20))
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(30))
            $0.height.equalTo(ZTScaleValue(13))
        }
        
        addBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(35))
            $0.height.equalTo(ZTScaleValue(22))
        }
        
        storagePoolCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
    }

}

extension StoragePoolCollectionView: UICollectionViewDelegate, UICollectionViewDataSource{
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentModel.lv.count
    }
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoragePoolPartitionCell.reusableIdentifier, for: indexPath) as! StoragePoolPartitionCell
        cell.setModel(model: currentModel.lv[indexPath.row])
        
        cell.statusCoverCallback = {[weak self] index in
            guard let self = self else { return }
            if index == 0 {// 重试
                NetworkManager.shared.restartAsyncTask(task_id: self.currentModel.lv[indexPath.row].task_id) { _ in
                    //页面刷新
                    self.actionCallback?(3,0)
                } failureCallback: { code, err in
                    SceneDelegate.shared.window?.makeToast(err)
                }
            }else{// 取消状态
                NetworkManager.shared.deleteAsyncTask(task_id: self.currentModel.lv[indexPath.row].task_id) { _ in
                    //页面刷新
                    self.actionCallback?(3,0)
                } failureCallback: { code, err in
                    SceneDelegate.shared.window?.makeToast(err)
                }
            }
            
//            switch self.currentModel.lv[indexPath.row].statusEnum {
//            case .failToDelete:
//                if index == 0 { // 删除分区失败 - 重试
//
//                }
//            case .failToEdit:
//                if index == 0 { // 修改分区失败 - 重试
//
//                }else{// 修改分区失败 - 取消修改
//
//                }
//
//            case .failToAdd:
//                if index == 0 {// 增加分区——重试
//
//                }else{// 增加分区失败——取消增加操作
//
//                }
//            default:
//                break
//
//            }

        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if currentModel.lv[indexPath.row].name == "__system__" || !currentModel.lv[indexPath.row].status.isEmpty{
            return
        }

        self.actionCallback?(2,indexPath.row)
    }
}
