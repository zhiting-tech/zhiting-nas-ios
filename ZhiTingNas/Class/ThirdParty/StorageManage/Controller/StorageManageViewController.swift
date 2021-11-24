//
//  StorageManageViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/28.
//

import UIKit

class StorageManageViewController: BaseViewController {
    /// Section类型
    enum SectionKind: Int, CaseIterable {
        /// 闲置硬盘
        case hardDisk
        /// 存储池
        case storagePool
        
        func scrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .hardDisk:
                return .groupPaging
            case .storagePool:
                return .none
            }
        }

    }
    
    
    /// 闲置硬盘数组
    private lazy var hardDisks = [PhysicalVolume]()
    
    /// 存储池数组
    private lazy var storagePools = [StoragePoolModel]()

    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "存储管理".localizedString
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
    
    var collectionView: UICollectionView!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        reloadData()
    }
    
    override func setupViews() {
        setupCollectionView()

    }
    

}

extension StorageManageViewController {
    
    @objc
    private func reloadData() {
        let semaphore = DispatchSemaphore(value: 1)
        if hardDisks.count == 0 && storagePools.count == 0 {
            showLoading(.custom(.white_ffffff))
        }
        
        DispatchQueue.global().async {
            semaphore.wait()
            
            /// 获取限制硬盘列表
            NetworkManager.shared.hardDiskList { [weak self] response in
                guard let self = self else { return }
                self.hardDisks = response.list
                semaphore.signal()

            } failureCallback: { code, err in
                semaphore.signal()
            }
            
            /// 挂起任务,等待硬盘列表结果
            semaphore.wait()
            
            /// 获取存储池列表
            /// 传0直接获取全部数据 不分页
            NetworkManager.shared.storagePoolList(page: 0, pageSize: 0) { [weak self] response in
                guard let self = self else { return }
                self.storagePools = response.list
                semaphore.signal()
                
            } failureCallback: { code, err in
                semaphore.signal()
                
            }
            
            /// 挂起任务,等待存储池列表结果
            semaphore.wait()
            
            DispatchQueue.main.async {
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.reloadData()
                self.hideLoading()
                semaphore.signal()
            }

        }
    }

}

// MARK: - CollectionView
extension StorageManageViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .custom(.white_ffffff)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(StoragePoolCell.self, forCellWithReuseIdentifier: StoragePoolCell.reusableIdentifier)
        collectionView.register(HardDiskCell.self, forCellWithReuseIdentifier: HardDiskCell.reusableIdentifier)
        collectionView.register(StorageManageSectionHeader.self, forSupplementaryViewOfKind: StorageManageSectionHeader.reusableIdentifier, withReuseIdentifier: StorageManageSectionHeader.reusableIdentifier)
        let header = GIFRefreshHeader()
        collectionView.mj_header = header
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadData))

        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20

        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] section, layoutEnv in
            guard let self = self else {
                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))))
                
            }
            
            var sectionKind: SectionKind!
            if section == 0 {
                if self.hardDisks.count == 0 {
                    sectionKind = .storagePool
                } else {
                    sectionKind = .hardDisk
                }
            } else {
                sectionKind = .storagePool
            }

           
            
            var itemWidth: NSCollectionLayoutDimension = .fractionalWidth(1)
            var itemHeight: NSCollectionLayoutDimension = .fractionalHeight(1)
            var groupWidth: NSCollectionLayoutDimension = .fractionalWidth(1)
            var groupHeight: NSCollectionLayoutDimension = .fractionalHeight(1)
            var itemContentInsets = NSDirectionalEdgeInsets()

            switch sectionKind {
            case .hardDisk:
                itemWidth = .fractionalWidth(1)
                itemHeight = .fractionalHeight(1)
                groupWidth = .fractionalWidth(0.62)
                groupHeight = .estimated(200.ztScaleValue)
                itemContentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15)
            case .storagePool:
                itemWidth = .fractionalWidth(0.5)
                itemHeight = .fractionalHeight(1)
                groupWidth = .fractionalWidth(1)
                groupHeight = .estimated(160.ztScaleValue)
                itemContentInsets = NSDirectionalEdgeInsets(top: 10, leading: 7.5, bottom: 10, trailing: 7.5)
            default:
                break
            }
            
            let storageItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight))
            storageItem.contentInsets = itemContentInsets

            let storageGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: groupWidth,
                    heightDimension: groupHeight),
                subitems: [storageItem])
            

            let section = NSCollectionLayoutSection(group: storageGroup)
            section.orthogonalScrollingBehavior = sectionKind.scrollingBehavior()

            if sectionKind == .hardDisk {
                section.contentInsets.trailing = 70.ztScaleValue
            }

            if sectionKind == SectionKind.storagePool {
                section.contentInsets.bottom = 70.ztScaleValue
                section.contentInsets.leading = 7.5
                section.contentInsets.trailing = 7.5
            }
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize:
                                                                                NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                       heightDimension: .estimated(44)),
                                                                            elementKind: StorageManageSectionHeader.reusableIdentifier,
                                                                            alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]

            return section

        }, configuration: config)
        
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var sectionKind: SectionKind!
        let section = indexPath.section
        if section == 0 {
            if hardDisks.count == 0 {
                sectionKind = .storagePool
            } else {
                sectionKind = .hardDisk
            }
        } else {
            sectionKind = .storagePool
        }
        
        switch sectionKind {
        case .hardDisk:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StorageManageSectionHeader.reusableIdentifier, for: indexPath) as! StorageManageSectionHeader
            header.title.text = "发现\(hardDisks.count)个可用硬盘,请添加到存储池".localizedString
            header.title.textColor = .custom(.gray_94a5be)
            return header
        case .storagePool:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StorageManageSectionHeader.reusableIdentifier, for: indexPath) as! StorageManageSectionHeader
            header.title.text = "存储池列表".localizedString
            header.title.textColor = .custom(.black_3f4663)
            return header
        default:
            return UICollectionReusableView()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var sectionKind: SectionKind!
        let section = indexPath.section
        if section == 0 {
            if hardDisks.count == 0 {
                sectionKind = .storagePool
            } else {
                sectionKind = .hardDisk
            }
        } else {
            sectionKind = .storagePool
        }
        
        switch sectionKind {
        case .hardDisk:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HardDiskCell.reusableIdentifier, for: indexPath) as! HardDiskCell
            var bgImg: UIImage?
            var btnColor: UIColor?
            
            if indexPath.row % 4 == 0 {
                bgImg = .assets(.hardDrive_bg1)
                btnColor = .custom(.blue_427aed)
            } else if indexPath.row % 4 == 1 {
                bgImg = .assets(.hardDrive_bg2)
                btnColor = .custom(.pink_ff7e6b)
            } else if indexPath.row % 4 == 2 {
                bgImg = .assets(.hardDrive_bg3)
                btnColor = .custom(.green_47d4ae)
            } else {
                bgImg = .assets(.hardDrive_bg4)
                btnColor = .custom(.orange_feb447)
            }

            let hardDisk = hardDisks[indexPath.row]
            
            cell.hardDisk = hardDisk
            cell.bgView.image = bgImg
            cell.addButton.setTitleColor(btnColor, for: .normal)
            
            cell.addBtnCallback = { [weak self] in
                guard let self = self else { return }
                let vc = AddToStoragePoolViewController()
                vc.disk_name = self.hardDisks[indexPath.row].name
                self.navigationController?.pushViewController(vc, animated: true)
            }

            return cell
        case .storagePool:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoragePoolCell.reusableIdentifier, for: indexPath) as! StoragePoolCell
            
            let pool = storagePools[indexPath.row]

            cell.storagePool = pool
            
            /// menu按钮回调
            cell.menuCallback = {
                let alert = HardDisksInfoAlert(hardDisks: pool.pv)
                SceneDelegate.shared.window?.addSubview(alert)
            }

            /// 状态cover 按钮回调
            cell.statusCoverCallback = { [weak self] index in
                guard let self = self else { return }
                switch pool.statusEnum {
                case .failToDelete:
                    if index == 0 { // 删除存储池失败 - 重试
                        self.showLoading()
                        NetworkManager.shared.restartAsyncTask(task_id: pool.task_id) { [weak self] _ in
                            guard let self = self else { return }
                            self.hideLoading()
                            self.reloadData()
                            
                        } failureCallback: { [weak self] code, err in
                            self?.hideLoading()
                            self?.showToast(err)
                        }

                    }

                default:
                    break
               
                }
            }
            
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoragePoolCell.reusableIdentifier, for: indexPath) as! StoragePoolCell
            
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var sectionKind: SectionKind!
        if section == 0 {
            if hardDisks.count == 0 {
                sectionKind = .storagePool
            } else {
                sectionKind = .hardDisk
            }
        } else {
            sectionKind = .storagePool
        }
        
        switch sectionKind {
        case .hardDisk:
            return hardDisks.count
        case .storagePool:
            return storagePools.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if hardDisks.count == 0 {
            return 1
        } else {
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var sectionKind: SectionKind!
        let section = indexPath.section
        if section == 0 {
            if hardDisks.count == 0 {
                sectionKind = .storagePool
            } else {
                sectionKind = .hardDisk
            }
        } else {
            sectionKind = .storagePool
        }
        
        switch sectionKind {
        case .hardDisk://闲置硬盘
            break
            
        case .storagePool://存储池列表
            let model = storagePools[indexPath.row]
            if model.status != "" {
                return
            }

            let storagePoolVC = StoragePoolViewController()
            storagePoolVC.currentStoragePoolName = model.name
            self.navigationController?.pushViewController(storagePoolVC, animated: true)
            
            
        default:
            break
        }
    }
}
