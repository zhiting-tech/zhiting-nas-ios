//
//  AddToStoragePoolViewController.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/15.
//

import UIKit


class AddToStoragePoolViewController: BaseViewController {
    var storagePools = [StoragePoolModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// 硬盘名称
    lazy var disk_name = ""
    
    var selectedIndex = 0
    
    /// 新存储池AlertView
    private var newStoragePoolAlert: SetNameAlertView?
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "添加到存储池".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navPop)))
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var navLeftBtn: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [navBackBtn, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    
    private lazy var sureBtn = LoadingButton().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.blue_427aed)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15.ztScaleValue
        
        let itemWH: CGFloat = (Screen.screenWidth - 45.ztScaleValue) / 2
        layout.itemSize = CGSize(width: itemWH, height: itemWH * 0.9)
    
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .custom(.white_ffffff)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(SelectCell.self, forCellWithReuseIdentifier: SelectCell.reusableIdentifier)
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: AddCell.reusableIdentifier)

        return collectionView
    }()


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }

    override func setupViews() {

        view.addSubview(collectionView)
        view.addSubview(sureBtn)

        sureBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if self.storagePools.count > 0 {
                self.save(storagePool: self.storagePools[self.selectedIndex])
            }
            
        }
    }
    
    override func setupConstraints() {
        sureBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight - 10.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.bottom.equalTo(sureBtn.snp.top)
        }
    }
    
    
    private func requestData() {
        /// 获取存储池列表
        /// 传0直接获取全部数据 不分页
        NetworkManager.shared.storagePoolList(page: 0, pageSize: 0) { [weak self] response in
            guard let self = self else { return }
            self.storagePools = response.list.filter({ $0.name != "__system__" })
            self.collectionView.reloadData()
            
        } failureCallback: { code, err in
            
            
        }
    }
    
    /// 保存(添加硬盘到存储池)
    private func save(storagePool: StoragePoolModel) {
        let tipsAlert = TipsAlertView(title: "添加到\(storagePool.name)", detail: "添加后，硬盘将会被格式化，里面的分区和文件都会删除，请确定是否添加？", warning: "操作不可撤销，请谨慎操作！", sureBtnTitle: "确定")
        tipsAlert.sureCallback = { [weak self] in
            guard let self = self else { return }

            tipsAlert.sureBtn.buttonState = .waiting
            NetworkManager.shared.addHardDiskToPool(pool_name: storagePool.name, disk_name: self.disk_name) { [weak self] _ in
                guard let self = self else { return }
                tipsAlert.sureBtn.buttonState = .normal
                
                SceneDelegate.shared.window?.makeToast("添加成功".localizedString)
                tipsAlert.removeFromSuperview()
                self.navigationController?.popViewController(animated: true)
                
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                tipsAlert.sureBtn.buttonState = .normal
                
                
                if code == 205 { // 磁盘挂载失败
                    tipsAlert.removeFromSuperview()
                    let singleTipsAlert = SingleTipsAlertView(detail: "硬盘(\(self.disk_name))添加到存储池(\(storagePool.name))失败，请重新添加。", detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                    singleTipsAlert.sureCallback = { [weak self] in
                        guard let self = self else { return }
                        singleTipsAlert.removeFromSuperview()
                        self.navigationController?.popViewController(animated: true)
                    }
                    SceneDelegate.shared.window?.addSubview(singleTipsAlert)
                } else {
                    SceneDelegate.shared.window?.makeToast(err)
                }
                
            }
        }
        
        SceneDelegate.shared.window?.addSubview(tipsAlert)

        
         
    }
    
    /// 添加到新存储池
    private func tapAddStorage() {
        print("点击添加到新的存储池")
        newStoragePoolAlert = SetNameAlertView(setNameType: .createStoragePool, currentName: "")
        newStoragePoolAlert?.setNameCallback = { [weak self] name in
            guard let self = self else { return }
            
            if name.isEmpty {
                SceneDelegate.shared.window?.makeToast("请输入名称".localizedString)
                return
            }
            
            if self.storagePools.map(\.name).contains(name) {
                SceneDelegate.shared.window?.makeToast("存储名称不能重复".localizedString)
                return
            }

            /// 请求添加存储池接口
            LoadingView.show()
            NetworkManager.shared.addStoragePool(name: name, disk_name: self.disk_name) { [weak self] _ in
                guard let self = self else { return }
                LoadingView.hide()
                SceneDelegate.shared.window?.makeToast("添加成功")
                self.newStoragePoolAlert?.removeFromSuperview()
                self.navigationController?.popViewController(animated: true)
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                LoadingView.hide()
                
                if code == 205 { // 磁盘挂载失败
                    self.newStoragePoolAlert?.removeFromSuperview()
                    let singleTipsAlert = SingleTipsAlertView(detail: "硬盘(\(self.disk_name))添加到存储池(\(name))失败，请重新添加。", detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                    singleTipsAlert.sureCallback = { [weak self] in
                        guard let self = self else { return }
                        singleTipsAlert.removeFromSuperview()
                        self.navigationController?.popViewController(animated: true)
                    }
                    SceneDelegate.shared.window?.addSubview(singleTipsAlert)
                } else {
                    SceneDelegate.shared.window?.makeToast(err)
                }
                

            }


        }
        SceneDelegate.shared.window?.addSubview(newStoragePoolAlert!)

    }

}

extension AddToStoragePoolViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storagePools.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < storagePools.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCell.reusableIdentifier, for: indexPath) as! SelectCell
            cell.isPicked = (selectedIndex == indexPath.row)
            cell.nameLabel.text = storagePools[indexPath.row].name
            cell.availaleSizeLabel.text = "可用容量: \(ZTCTool.convertFileSize(size:storagePools[indexPath.row].capacity - storagePools[indexPath.row].use_capacity))"
            cell.sizeLabel.text = "总容量: \(ZTCTool.convertFileSize(size:storagePools[indexPath.row].capacity))"

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCell.reusableIdentifier, for: indexPath)
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < storagePools.count {
            selectedIndex = indexPath.row
            collectionView.reloadData()
        } else {
            tapAddStorage()
        }
        
        
    }

    
}



// MARK: - SelectCell
extension AddToStoragePoolViewController {
    class SelectCell: UICollectionViewCell, ReusableView {
        var isPicked = false {
            didSet {
                selectedBtn.image = isPicked ? .assets(.selected_whiteBG) : .assets(.unselected_tick)
                backgroundColor = isPicked ? .custom(.blue_427aed) : .custom(.gray_f2f5fa)
                nameLabel.textColor = isPicked ? .custom(.white_ffffff) : .custom(.black_3f4663)
                sizeLabel.textColor = isPicked ? .custom(.white_ffffff) : .custom(.black_3f4663)
                availaleSizeLabel.textColor = isPicked ? .custom(.white_ffffff) : .custom(.black_3f4663)
            }
        }


        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.icon_storagePool)
        }
        
        lazy var selectedBtn = ImageView().then {
            $0.image = .assets(.fileSelected_normal)
            $0.contentMode = .scaleAspectFit
        }

        
        lazy var nameLabel = UILabel().then {
            $0.font = .font(size: 16.ztScaleValue, type: .bold)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "存储池".localizedString
        }
        
        lazy var sizeLabel = UILabel().then {
            $0.font = .font(size: 11.ztScaleValue, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "0GB".localizedString
        }

        lazy var availaleSizeLabel = UILabel().then {
            $0.font = .font(size: 11.ztScaleValue, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "0GB".localizedString
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .custom(.gray_f2f5fa)
            clipsToBounds = true
            layer.cornerRadius = 10
            
            
            contentView.addSubview(icon)
            contentView.addSubview(selectedBtn)
            contentView.addSubview(nameLabel)
            contentView.addSubview(availaleSizeLabel)
            contentView.addSubview(sizeLabel)

        }
        
        private func setupConstraints() {
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(19.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.height.equalTo(36.ztScaleValue)
                $0.width.equalTo(33.5.ztScaleValue)
            }
            
            selectedBtn.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.right.equalToSuperview().offset(-10)
                $0.width.height.equalTo(16)
            }
            
            nameLabel.snp.makeConstraints {
                $0.top.equalTo(icon.snp.bottom).offset(15.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.right.equalToSuperview().offset(-20.ztScaleValue)
            }
            
            sizeLabel.snp.makeConstraints {
                $0.top.equalTo(nameLabel.snp.bottom).offset(5.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.right.equalToSuperview().offset(-20.ztScaleValue)
            }
            
            availaleSizeLabel.snp.makeConstraints {
                $0.top.equalTo(sizeLabel.snp.bottom).offset(5.ztScaleValue)
                $0.left.equalToSuperview().offset(20.ztScaleValue)
                $0.right.equalToSuperview().offset(-20.ztScaleValue)
                
            }
            
        }

        
    }
    
    
    class AddCell: UICollectionViewCell, ReusableView {
        private lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.circle_add)
        }
        

        
        lazy var nameLabel = UILabel().then {
            $0.font = .font(size: 14.ztScaleValue, type: .bold)
            $0.textColor = .custom(.blue_427aed)
            $0.text = "添加到新的存储池".localizedString
            $0.textAlignment = .center
        }
        

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .custom(.gray_f2f5fa)
            clipsToBounds = true
            layer.cornerRadius = 10
            
            contentView.addSubview(icon)
            contentView.addSubview(nameLabel)
            

        }
        
        private func setupConstraints() {
            icon.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-10.ztScaleValue)
                $0.height.width.equalTo(40.ztScaleValue)
            }

            nameLabel.snp.makeConstraints {
                $0.top.equalTo(icon.snp.bottom).offset(14.ztScaleValue)
                $0.centerX.equalToSuperview()
            }
            
        }

        
    }
}

