//
//  MineViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit

class MineViewController: BaseViewController {
    
    private lazy var headerView = MineUserInfoHeaderView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var areaSelectView = SwtichAreaView()
    
    var cellRows: [MineCell.MineCellType] = [.document]

    private lazy var settingAlert = MineSettingAlert(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    
    private lazy var tableViewContainerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowRadius = 8
        $0.layer.shadowOffset = CGSize(width: ZTScaleValue(-0.1), height: ZTScaleValue(-0.1))
        
    }

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.custom(.gray_fafafa).cgColor
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.alwaysBounceVertical = false
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    deinit {
        if observationInfo != nil {
            tableView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: - funtion
    override func setupViews() {
        view.addSubview(headerView)
        view.addSubview(tableViewContainerView)
        view.addSubview(tableView)
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        headerView.settingBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.settingAlert)
        }
        
        settingAlert.items = [.init(title: "退出登录".localizedString, icon: .assets(.logout))]
        settingAlert.selectCallback = { [weak self] item in
            if item.title == "退出登录".localizedString {
                HTTPCookieStorage.shared.removeCookies(since: Date.init(timeIntervalSince1970: 0))
                AreaManager.shared.clearAreas()
                self?.showToast("退出成功".localizedString)
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                SceneDelegate.shared.window?.rootViewController = nav
            }
        }
        
        headerView.tapSelectArea = { [weak self] in
            guard let self = self else { return }
            print("切换家庭")
            SceneDelegate.shared.window?.addSubview(self.areaSelectView)
        }
        
        // MARK: - selectAreaAction
        areaSelectView.areas = AreaManager.shared.getAreaList()
        if AreaManager.shared.currentArea.name != "" {
            headerView.titleLabel.text = AreaManager.shared.currentArea.name
        }
        areaSelectView.selectCallback = { area in
            AreaManager.shared.currentArea = area
        }
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(25.ztScaleValue)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(100.ztScaleValue)
        }
        
        tableViewContainerView.snp.makeConstraints {
            $0.edges.equalTo(tableView)
        }
    }
    
    override func setupSubscriptions() {
        AreaManager.shared.currentAreaPublisher
            .sink { [weak self] area in
                guard let self = self else { return }
                self.areaSelectView.tableView.reloadData()
                self.headerView.titleLabel.text = area.name
                
            }
            .store(in: &cancellables)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + ZTScaleValue(100) > Screen.screenHeight ? Screen.screenHeight - ZTScaleValue(120) : height
            tableView.snp.updateConstraints {
                $0.height.equalTo(tableViewHeight)
            }

        }
    }

}

extension MineViewController {
    private func getUserInfo() {
        let id = AreaManager.shared.currentArea.sa_user_id

        NetworkManager.shared.userDetail(id: id) { [weak self] response in
            guard let self = self else { return }
            self.headerView.userName.text = response.nickname
            if response.is_owner == true {
                self.cellRows = [.storage, .document]
                self.tableView.reloadData()
            } else {
                self.cellRows = [.document]
                self.tableView.reloadData()
            }
            

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.headerView.userName.text = UserManager.shared.currentUser.nickname
            self.cellRows = [.document]
            self.tableView.reloadData()
        }

    }
}

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = cellRows[indexPath.row]
        return MineCell(type: type)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = cellRows[indexPath.row]
        switch type {
        case .storage:
            let vc = StorageManageViewController()
            navigationController?.pushViewController(vc, animated: true)

        case .document:
            let vc = FolderManageViewController()
            navigationController?.pushViewController(vc, animated: true)

        }

    }
}
