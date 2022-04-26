//
//  FolderManageViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/30.
//

import UIKit
import MJRefresh


class FolderManageViewController: BaseViewController {
    /// 文件夹数组
    private lazy var folders = [FolderModel]()
    

    
    /// 设置按钮
    private lazy var settingBtn = UIButton().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("设置".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSetting)))
    }
    
    /// 新增文件夹按钮
    private lazy var createBtn = Button().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("新增".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.blue_427aed)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "文件夹".localizedString
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingBtn)
        reloadData()
        
    }
    
    override func setupViews() {
        setupCollectionView()
        view.addSubview(collectionView)
        view.addSubview(createBtn)
        
        createBtn.clickCallBack = { [weak self] _ in
            let vc = EditFolderViewController(type: .create)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func setupConstraints() {
        createBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight - 15)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(createBtn.snp.top).offset(-15)
        }

    }


}

extension FolderManageViewController {
    @objc
    private func tapSetting() {
        let vc = FolderManageSettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc
    private func reloadData() {
        folders.removeAll()
        requestData()
    }
    
    @objc
    private func loadMore() {
        requestData()
    }

    private func requestData() {
        if folders.count == 0 {
            showLoading()
        }
        
        let page = (folders.count / 30) + 1

        NetworkManager.shared.folderList(page: page, pageSize: 30) { [weak self] response in
            guard let self = self else { return }
            self.hideLoading()
            self.folders.append(contentsOf: response.list)
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            if !response.pager.has_more {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.collectionView.reloadData()

        } failureCallback: { [weak self] code, err in
            self?.collectionView.mj_header?.endRefreshing()
            self?.collectionView.mj_footer?.endRefreshing()
            self?.collectionView.reloadData()
            self?.hideLoading()
            self?.showToast(err)
        }

    }

}

// MARK: - CollectionView
extension FolderManageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemW: CGFloat = (Screen.screenWidth - 45.ztScaleValue) / 2
        layout.itemSize = CGSize(width: itemW, height: itemW * 0.85)
        layout.minimumLineSpacing = 15.ztScaleValue
        layout.minimumInteritemSpacing = 15.ztScaleValue
        

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .custom(.white_ffffff)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.left = 15.ztScaleValue
        collectionView.contentInset.right = 15.ztScaleValue
        collectionView.register(FolderManageCell.self, forCellWithReuseIdentifier: FolderManageCell.reusableIdentifier)
        let header = GIFRefreshHeader()
        collectionView.mj_header = header
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reloadData))
        
        collectionView.mj_footer = MJRefreshBackNormalFooter()
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadMore))

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderManageCell.reusableIdentifier, for: indexPath) as! FolderManageCell
        
        let folder = folders[indexPath.row]
        cell.folder = folder
        
        /// menu按钮回调
        cell.menuCallback = { [weak self] in
            guard let self = self, let cell = self.collectionView.cellForItem(at: indexPath) else { return }
            let x = 35.ztScaleValue
            let y = 50.ztScaleValue
            let alertPoint = cell.convert(CGPoint(x: x, y: y), to: self.view)
            let alert = MenuAlert(items: [.init(title: "更改密码", icon: .assets(.icon_lock))], alertPoint: alertPoint)
            alert.selectCallback = { [weak self] item in
                guard let self = self else { return }
                if item.title == "更改密码" {
                    let alert = FolderEditPwdAlert()
                    alert.saveCallback = { [weak self] old, new, confrim in
                        guard let self = self else { return }
                        LoadingView.show()
                        NetworkManager.shared.editFolderPwd(id: folder.id, oldPwd: old, newPwd: new, confirmPwd: confrim) { [weak self] _ in
                            guard let self = self else { return }
                            alert.removeFromSuperview()
                            LoadingView.hide()
                            SceneDelegate.shared.window?.makeToast("修改成功".localizedString)
                            self.reloadData()
                            

                        } failureCallback: { code, err in
                            LoadingView.hide()
                            SceneDelegate.shared.window?.makeToast(err)
                        }


                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                }
            }
            SceneDelegate.shared.window?.addSubview(alert)

        }
        
        
        /// 状态cover 按钮回调
        cell.statusCoverCallback = { [weak self] index in
            guard let self = self else { return }
            switch folder.statusEnum {
            case .failToDelete:
                if index == 0 { // 修改文件夹失败 - 重试
                    self.showLoading()
                    NetworkManager.shared.restartAsyncTask(task_id: folder.task_id) { [weak self] _ in
                        guard let self = self else { return }
                        self.hideLoading()
                        self.reloadData()
                        
                    } failureCallback: { [weak self] code, err in
                        self?.hideLoading()
                        self?.showToast(err)
                    }
                }
            case .failToEdit:
                if index == 0 { // 修改文件夹失败 - 确定
                    self.showLoading()
                    NetworkManager.shared.deleteAsyncTask(task_id: folder.task_id) { [weak self] _ in
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if folders[indexPath.row].status != "" {
            return
        }

        let id = folders[indexPath.row].id
        let vc = EditFolderViewController(type: .edit(folderId: id))
        navigationController?.pushViewController(vc, animated: true)
        

    }
    
    

    
    
}
