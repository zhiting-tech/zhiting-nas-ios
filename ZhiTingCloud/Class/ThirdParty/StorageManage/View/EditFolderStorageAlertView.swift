//
//  EditFolderStorageAlertView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/7/5.
//

import UIKit

enum ButtonSeletedType {
    case StoragePool
    case Partition
}


class EditFolderStorageAlertView: UIView {
    var selectCallback: ((_ storagePool: StoragePoolModel?, _ partition: LogicVolume?) -> ())?

    var currentSected = ButtonSeletedType.StoragePool

    var storagePoolItems = [StoragePoolModel]()
    var partitionItems = [LogicVolume]()
    
    var choosedStorageModel : StoragePoolModel?
    var choosedPartitionModel : LogicVolume?
    
    private lazy var emptyView = EmptyView()
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }

    private lazy var storagePoolButton = Button().then {
        $0.setTitle("请选择存储池", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .selected)
        $0.tag = 1
        $0.titleLabel?.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }
    
    private lazy var partitionButton = Button().then {
        $0.setTitle("请选择分区", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .selected)
        $0.tag = 2
        $0.titleLabel?.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }

    private lazy var cancleButton = Button().then {
        $0.setTitle("取消", for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.tag = 3
        $0.titleLabel?.font = .font(size: ZTScaleValue(16), type: .medium)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }

    private lazy var seperatorLine = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }

    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = true
        $0.separatorColor = .custom(.gray_eeeeee)
        $0.register(EditFolderStorageCell.self, forCellReuseIdentifier: EditFolderStorageCell.reusableIdentifier)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(isCancle: Bool,callback: ((_ storagePool: StoragePoolModel?, _ partition: LogicVolume?) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
//        reload(storagePool: choosedStorageModel, partitionModel: choosedPartitionModel)
        self.selectCallback = callback
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reload(storagePools: [StoragePoolModel], storagePool: StoragePoolModel?, partitionModel: LogicVolume?){
        setupDatas(storagePools: storagePools, storagePool:storagePool, partitionModel:partitionModel)
        tableView.reloadData()
    }
    
    private func setupDatas(storagePools: [StoragePoolModel], storagePool: StoragePoolModel?, partitionModel: LogicVolume?){
        storagePoolItems = storagePools

        if let pool = storagePool {
            partitionItems = pool.lv
        }
        
        //判断是否传入已选中的存储池和分区
        choosedStorageModel = storagePool
        choosedPartitionModel = partitionModel
        
        if storagePool != nil {
            storagePools.forEach { $0.isSelected = false }
            choosedStorageModel?.isSelected = true
            if let name = storagePool?.name {
                if name.count <= 16 {
                    storagePoolButton.setTitle(name, for: .normal)
                } else {
                    storagePoolButton.setTitle(String(name.prefix(16)) + "...", for: .normal)
                }
            }
            
        }else{
            storagePoolButton.setTitle("请选择存储池", for: .normal)
        }
        
        if partitionModel != nil {
            partitionItems.forEach { $0.isSelected = false }
            choosedPartitionModel?.isSelected = true
            if let name = partitionModel?.name {
                if name.count <= 16 {
                    partitionButton.setTitle(name, for: .normal)
                } else {
                    partitionButton.setTitle(String(name.prefix(16)) + "...", for: .normal)
                }
            }
            
        }else{
            partitionButton.setTitle("请选择分区", for: .normal)
        }
        
        //进入是需显示存储池列表
        buttonOnPress(sender: storagePoolButton)
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(storagePoolButton)
        containerView.addSubview(partitionButton)
        containerView.addSubview(cancleButton)
        containerView.addSubview(seperatorLine)
        containerView.addSubview(tableView)

        currentSected = .StoragePool
        storagePoolButton.isSelected = true
        partitionButton.isSelected = false
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(450))
        }
        
        storagePoolButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(19))
            $0.left.equalToSuperview().offset(ZTScaleValue(14.5))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(80))
            $0.height.equalTo(ZTScaleValue(16))
        }
        
        partitionButton.snp.makeConstraints {
            $0.centerY.equalTo(storagePoolButton)
            $0.left.equalTo(storagePoolButton.snp.right).offset(ZTScaleValue(27))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(80))
            $0.height.equalTo(ZTScaleValue(16))
        }
        
        cancleButton.snp.makeConstraints {
            $0.centerY.equalTo(storagePoolButton)
            $0.right.equalToSuperview().offset(-ZTScaleValue(14.5))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
            $0.height.equalTo(ZTScaleValue(16))
        }
        
        seperatorLine.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(50))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(seperatorLine.snp.bottom).offset(ZTScaleValue(10))
            $0.bottom.equalToSuperview()
        }
    }
}

extension EditFolderStorageAlertView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSected == .StoragePool {
            emptyView.removeFromSuperview()
            return storagePoolItems.count
            
        } else {
            if partitionItems.count == 0 {
                containerView.addSubview(emptyView)
                emptyView.snp.makeConstraints {
                    $0.edges.equalTo(tableView)
                }
            } else {
                emptyView.removeFromSuperview()
            }
            
            return partitionItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(70)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditFolderStorageCell.reusableIdentifier, for: indexPath) as! EditFolderStorageCell
        cell.selectionStyle = .none
        if currentSected == .StoragePool {
            cell.setStoragePoolModel(currentModel: storagePoolItems[indexPath.row])
        }else{
            cell.setPartitionModel(currentModel: partitionItems[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentSected {
        case .StoragePool:
            if (choosedStorageModel?.name ?? "") != storagePoolItems[indexPath.row].name {
                choosedPartitionModel?.isSelected = false
                choosedPartitionModel = nil
            }

            for (index,model) in storagePoolItems.enumerated() {
                if index == indexPath.row {
                    model.isSelected = true
                }else{
                    model.isSelected = false
                }
            }
            
            choosedStorageModel = storagePoolItems[indexPath.row]
            
            if storagePoolItems[indexPath.row].name.count <= 16 {
                storagePoolButton.setTitle(storagePoolItems[indexPath.row].name, for: .normal)
            } else {
                storagePoolButton.setTitle(String(storagePoolItems[indexPath.row].name.prefix(16)) + "...", for: .normal)
            }
            
            
            
            //切换为partition数据
            self.buttonOnPress(sender: partitionButton)

        case .Partition:
            if !(partitionItems[indexPath.row].isSelected ?? false) {
                for (index,model) in partitionItems.enumerated() {
                    if index == indexPath.row {
                        model.isSelected = true
                    }else{
                        model.isSelected = false
                    }
                }
                choosedPartitionModel = partitionItems[indexPath.row]
                if partitionItems[indexPath.row].name.count <= 16 {
                    partitionButton.setTitle(partitionItems[indexPath.row].name, for: .normal)
                } else {
                    partitionButton.setTitle(String(partitionItems[indexPath.row].name.prefix(16)) + "...", for: .normal)
                }
                
            }
            if choosedStorageModel != nil && choosedPartitionModel != nil {
                dismissWithCallback(choosedStorageModel!, choosedPartitionModel!)
                self.tableView.reloadData()
            }else{
                self.tableView.reloadData()
            }
        }
        
    }
}

extension EditFolderStorageAlertView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
    }
    
    private func removeAllDatas(){
        storagePoolItems.forEach { $0.isSelected = false }
        partitionItems.forEach { $0.isSelected = false }
        choosedStorageModel = nil
        choosedPartitionModel = nil
        storagePoolItems.removeAll()
        partitionItems.removeAll()
        tableView.reloadData()
    }
    
    override func removeFromSuperview() {
        removeAllDatas()
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
    }
    
    @objc private func dismiss() {
        removeAllDatas()
        removeFromSuperview()
    }

    private func dismissWithCallback(_ storagePool: StoragePoolModel, _ partition: LogicVolume) {
        removeAllDatas()
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            weakSelf?.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                weakSelf?.selectCallback?(storagePool, partition)
                super.removeFromSuperview()
            }
        })
    }

    @objc func buttonOnPress(sender:Button) {
        
        switch sender.tag {
        case 1://storagePool
            if currentSected == .StoragePool {
                break
            }else{
                storagePoolButton.isSelected = true
                partitionButton.isSelected = false
                currentSected = .StoragePool
                self.tableView.reloadData()
            }
        case 2://partition
            if currentSected == .Partition {
                break
            }else{
                if choosedPartitionModel == nil {
                    partitionButton.setTitle("请选择分区", for: .normal)
                }
                storagePoolButton.isSelected = false
                partitionButton.isSelected = true
                currentSected = .Partition
                if let pool = choosedStorageModel {
                    partitionItems = pool.lv
                }
                
                self.tableView.reloadData()
          }
        case 3://cancel
            self.removeFromSuperview()
        default:
            break
        }
        
    }

}


extension EditFolderStorageAlertView {
    class EmptyView: UIView {
        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.empty_partition)
        }
        
        private lazy var label = UILabel().then {
            $0.font = .font(size: 14.ztScaleValue, type: .regular)
            $0.textColor = .custom(.gray_94a5be)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "当前存储池无分区，请添加分区后重新选择或选择其他存储池的分区"
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .custom(.white_ffffff)
            addSubview(icon)
            addSubview(label)
            icon.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-30.ztScaleValue)
                $0.height.width.equalTo(102.ztScaleValue)
            }

            label.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(icon.snp.bottom)
                $0.left.equalToSuperview().offset(55.ztScaleValue)
                $0.right.equalToSuperview().offset(-55.ztScaleValue)
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
