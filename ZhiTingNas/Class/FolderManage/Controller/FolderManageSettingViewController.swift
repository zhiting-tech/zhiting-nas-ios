//
//  FolderManageSettingViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/30.
//

import UIKit

class FolderManageSettingViewController: BaseViewController {
    
    /// 存储池列表
    var storagePools = [StoragePoolModel]()
    /// 选择的存储池
    var selectedPool: StoragePoolModel?
    /// 选择的分区
    var selectedPartition: LogicVolume?
    
    /// 设置按钮
    private lazy var settingBtn = UIButton().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSave)))
    }
    

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "设置".localizedString
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
    
    private lazy var storageDefaultCell = FolderManageSetDefaultCell()
    
    private lazy var autoDeleteCell = FolderManageSetDeleteCell()



    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
    }
    
    /// 存储分区alert
    private lazy var editFolderStorageAlertView = EditFolderStorageAlertView(isCancle: true).then {
        $0.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingBtn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFolderSettings()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        storageDefaultCell.nameLabelCallback = { [weak self] in
            guard let self = self else { return }
            self.editFolderStorageAlertView.reload(storagePools: self.storagePools, storagePool: self.selectedPool, partitionModel: self.selectedPartition)
            SceneDelegate.shared.window?.addSubview(self.editFolderStorageAlertView)
        }
        
        editFolderStorageAlertView.selectCallback = { [weak self] pool, lv in
            guard let self = self, let pool = pool, let lv = lv else { return }
            self.selectedPool = pool
            self.selectedPartition = lv
            self.storageDefaultCell.nameLabel.text = "\(pool.name)-\(lv.name)"
            
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

extension FolderManageSettingViewController {
    /// 保存文件夹设置
    @objc
    private func tapSave() {
        guard let pool = selectedPool, let partition = selectedPartition else { return }

        showLoading()
        
        NetworkManager.shared.setFolderSettings(poolName: pool.name, partitionName: partition.name, autoDel: autoDeleteCell.switchBtn.isOn) { [weak self] _ in
            self?.hideLoading()
            SceneDelegate.shared.window?.makeToast("保存成功".localizedString)
            self?.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] code, err in
            self?.hideLoading()
            self?.showToast(err)
        }

    }
    
    
    /// 获取文件夹设置
    private func getFolderSettings() {
        showLoading(.custom(.white_ffffff))
        
        let sp = DispatchSemaphore(value: 1)
        
        DispatchQueue.global().async {
            sp.wait()
            /// 1获取存储池列表
            NetworkManager.shared.storagePoolList(page: 0, pageSize: 0) { [weak self] response in
                guard let self = self else { return }
                self.storagePools = response.list
                sp.signal()

            } failureCallback: { _, _ in
                sp.signal()
            }

            sp.wait()
            
            NetworkManager.shared.getFolderSettings { [weak self] settings in
                sp.signal()
                guard let self = self else { return }
                self.hideLoading()
                self.autoDeleteCell.switchBtn.setIsOn(settings.is_auto_del) 
                self.storageDefaultCell.nameLabel.text = "\(settings.pool_name)-\(settings.partition_name)"
                self.selectedPool = self.storagePools.first(where: { $0.name == settings.pool_name })
                if let selectedPool = self.selectedPool {
                    self.selectedPartition = selectedPool.lv.first(where: { $0.name == settings.partition_name })
                }
                
            } failureCallback: { [weak self] code, err in
                sp.signal()
                self?.hideLoading()
                self?.showToast(err)
            }
            
        }
    }
    
    
}

extension FolderManageSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return storageDefaultCell
        } else {
            return autoDeleteCell
        }
    }
    
    
}
