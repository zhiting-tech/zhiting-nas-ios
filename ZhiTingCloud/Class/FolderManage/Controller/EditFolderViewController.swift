//
//  EditFolderViewController.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/1.
//

import UIKit
import Combine

class EditFolderViewController: BaseViewController {
    /// vc类型
    enum EditType: Equatable {
        /// 新增文件夹
        case create
        /// 编辑文件夹
        case edit(folderId: Int)
        
        var folderId: Int? {
            switch self {
            case .create:
                return nil
            case .edit(let id):
                return id
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            var flag1 = 0
            var flag2 = 0
            switch lhs {
            case .create:
                flag1 = 0
            default:
                flag1 = 1
            }
            
            switch rhs {
            case .create:
                flag2 = 0
            default:
                flag2 = 1
            }
            
            return flag1 == flag2
        }
        
    }
    
    /// vc类型
    var type: EditType!
    
    var validatePublisher = PassthroughSubject<Void, Never>()
    
    /// 已添加成员
    var members = [User]()
    
    /// infoCells
    var infoCellTypes = [InfoCellType]()
    
    /// 存储池列表
    var storagePools = [StoragePoolModel]()
    /// 选择的存储池
    var selectedPool: StoragePoolModel?
    /// 选择的分区
    var selectedPartition: LogicVolume?

    /// 文件夹详情
    var folder: FolderModel?

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "新增文件夹".localizedString
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
    
    /// 删除按钮
    private lazy var deleteBtn = UIButton().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("删除".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDelete)))
    }
    
    /// 文件夹信息tableView
    private lazy var infoTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.rowHeight = 50.ztScaleValue
        $0.delegate = self
        $0.dataSource = self
    }
    
    /// 成员信息tableView
    private lazy var memberTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.register(EditFolderMemberCell.self, forCellReuseIdentifier: EditFolderMemberCell.reusableIdentifier)
    }
    
    /// 空成员view
    private lazy var emptyMemberView = FolderManageEmptyMemberView(frame: .zero)
    
    /// 存储分区alert
    private lazy var editFolderStorageAlertView = EditFolderStorageAlertView(isCancle: true).then {
        $0.backgroundColor = .clear
    }
    
    /// 保存按钮
    private lazy var saveBtn = Button().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .custom(.blue_427aed)
        $0.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
    
    private lazy var nameCell = EditFolderCell(type: .textField(title: "名称", placeHolder: "请输入", isSecure: false))
    
    private lazy var storageCell = EditFolderCell(type: .rightButton(title: "储存分区", placeHolder: "请选择"))

    private lazy var folderTypeCell = EditFolderCell(type: .selectView(title: "类型", selection1: "私人文件夹", selection2: "共享文件夹"))
    
    private lazy var isSecureCell = EditFolderCell(type: .selectView(title: "是否加密", selection1: "是", selection2: "否"))

    private lazy var pwdCell1 = EditFolderCell(type: .textField(title: "密码", placeHolder: "请输入,不能少于6位", isSecure: true))
    
    private lazy var pwdCell2 = EditFolderCell(type: .textField(title: "确认密码", placeHolder: "请再次输入,不能少于6位", isSecure: true))
    
    private lazy var line1 = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }
    
    private lazy var line2 = UIView().then {
        $0.backgroundColor = .custom(.gray_f2f5fa)
    }
    
    
    private lazy var addMemberHeader = EditFolderMemberHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 55))


    convenience init(type: EditType) {
        self.init()
        self.type = type
    }

    deinit {
        if infoTableView.observationInfo != nil {
            infoTableView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setType(type: type)
        infoTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func setType(type: EditType) {
        switch type {
        case .create:
            getStoragePools()
            self.isSecureCell.selectView.item1.alpha = 0.3
            self.isSecureCell.selectView.item1.isUserInteractionEnabled = false
            titleLabel.text = "新增文件夹"
            saveBtn.isEnabled = false
            saveBtn.alpha = 0.5
            infoCellTypes = [.name, .storage, .folderType]
            self.folderTypeCell.selectView.selectedIndex = -1
            infoTableView.reloadData()
        case .edit:
            titleLabel.text = "编辑文件夹"
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteBtn)
            getFolderDetail()
            
        }
    }


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard var height = (change![.newKey] as? CGSize)?.height else {
                return
            }
            
            if height > Screen.screenHeight - 20 - ZTScaleValue(Screen.bottomSafeAreaHeight + 15) - 50 {
                height = Screen.screenHeight - 20 - ZTScaleValue(Screen.bottomSafeAreaHeight + 15) - 50
            }

            infoTableView.snp.updateConstraints {
                $0.height.equalTo(height)
            }

        }
    }

    override func setupViews() {
        view.addSubview(infoTableView)
        view.addSubview(saveBtn)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(addMemberHeader)
        view.addSubview(memberTableView)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        isSecureCell.selectIndexCallback = { [weak self] index in
            guard let self = self else { return }
            if index == 0 {
                self.infoCellTypes = [.name, .storage, .folderType, .secure, .pwd1, .pwd2]
            } else {
                self.infoCellTypes = [.name, .storage, .folderType, .secure]
            }
            self.infoTableView.reloadData()
        }
        
        folderTypeCell.selectIndexCallback = { [weak self] index in
            guard let self = self else { return }
            if index == 0 { // 私人文件夹
                if self.members.count > 1 {
                    self.folderTypeCell.selectView.selectedIndex = 1
                    self.showToast("“私人文件夹”，则只能有一个成员")
                    return
                }
                if self.type == .create {
                    self.isSecureCell.selectView.selectedIndex = 1
                    self.isSecureCell.selectView.item1.alpha = 1
                    self.isSecureCell.selectView.item1.isUserInteractionEnabled = true
                }
                self.infoCellTypes = [.name, .storage, .folderType, .secure]
            } else { // 共享文件夹
 
                self.pwdCell1.textField.text = ""
                self.pwdCell2.textField.text = ""
                if self.type == .create {
                    self.isSecureCell.selectView.selectedIndex = 1
                    self.isSecureCell.selectView.item1.alpha = 0.3
                    self.isSecureCell.selectView.item1.isUserInteractionEnabled = false
                    self.infoCellTypes = [.name, .storage, .folderType]
                } else {
                    self.infoCellTypes = [.name, .storage, .folderType, .secure]
                }
                
            }
            
            self.infoTableView.reloadData()
        }
        
        storageCell.tapBtnCallback = { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.editFolderStorageAlertView.reload(storagePools: self.storagePools, storagePool: self.selectedPool, partitionModel: self.selectedPartition)
            SceneDelegate.shared.window?.addSubview(self.editFolderStorageAlertView)
            
        }
        
        editFolderStorageAlertView.selectCallback = { [weak self] pool, lv in
            guard let self = self, let pool = pool, let lv = lv else { return }
            self.selectedPool = pool
            self.selectedPartition = lv
            self.storageCell.detailLabel.text = "\(pool.name)-\(lv.name)"
            self.storageCell.detailLabel.textColor = .custom(.black_3f4663)
            self.validatePublisher.send(())
        }

        
        addMemberHeader.addButton.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            if self.members.count > 0 {
                if self.folderTypeCell.selectView.selectedIndex == 0 {
                    self.showToast("“私人文件夹”，则只能有一个成员")
                    return
                }
            }
            
            let vc = AddMemberViewController()
            vc.defaultSelectMembers = self.members
            vc.isPrivateFolder = self.folderTypeCell.selectView.selectedIndex == 0
            
            
            vc.saveCallback = { [weak self] users in
                guard let self = self else { return }
                self.members.append(contentsOf: users)
                self.memberTableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        emptyMemberView.addBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            let vc = AddMemberViewController()
            vc.defaultSelectMembers = self.members
            
            if self.type == .create {
                vc.isPrivateFolder = self.folderTypeCell.selectView.selectedIndex == 0
            } else {
                vc.isPrivateFolder = self.folder?.folderMode == .private
            }
            
            vc.saveCallback = { [weak self] users in
                guard let self = self else { return }
                self.members.append(contentsOf: users)
                self.memberTableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        

    }
    
    override func setupConstraints() {
        saveBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight - 15)
        }
        
        line1.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.height.equalTo(10)
        }

        infoTableView.snp.makeConstraints {
            $0.top.equalTo(line1.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(200.ztScaleValue)
        }
        
        line2.snp.makeConstraints {
            $0.top.equalTo(infoTableView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        addMemberHeader.snp.makeConstraints {
            $0.top.equalTo(line2.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(55)
        }
        
        memberTableView.snp.makeConstraints {
            $0.top.equalTo(addMemberHeader.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(saveBtn.snp.top).offset(-10)
        }


    }
    
    override func setupSubscriptions() {
        validatePublisher
            .merge(with: storageCell.validatePublisher,
                   folderTypeCell.validatePublisher,
                   isSecureCell.validatePublisher,
                   pwdCell1.validatePublisher,
                   pwdCell2.validatePublisher,
                   nameCell.validatePublisher)
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard
                    let nameCellText = self.nameCell.textField.text,
                    let pwdCellText = self.pwdCell1.textField.text,
                    let pwdCell2Text = self.pwdCell2.textField.text
                else {
                    return
                }
                
                if self.type == .create {
                    var flag = false
                    if !nameCellText.isEmpty
                        && self.selectedPartition != nil
                        && self.selectedPartition != nil
                        && self.folderTypeCell.selectView.selectedIndex == 1
                        && self.members.count > 0 {
                        flag = true
                    } else if !nameCellText.isEmpty
                                && self.selectedPartition != nil
                                && self.selectedPartition != nil
                                && self.folderTypeCell.selectView.selectedIndex == 0
                                && self.members.count > 0 {
                        if self.isSecureCell.selectView.selectedIndex == 0 {
                            if !pwdCellText.isEmpty && !pwdCell2Text.isEmpty {
                                flag = true
                            } else {
                                flag = false
                                if self.folder?.is_encrypt == 1 {
                                    flag = true
                                }
                            }
                            
                        } else {
                            flag = true
                        }
                    }
                    
                    if flag {
                        self.saveBtn.isEnabled = true
                        self.saveBtn.alpha = 1
                    } else {
                        self.saveBtn.isEnabled = false
                        self.saveBtn.alpha = 0.5
                    }
                    
                } else {
                    var flag = false
                    if !nameCellText.isEmpty && self.members.count > 0 && self.selectedPartition != nil
                        && self.selectedPartition != nil {
                        flag = true
                    }
                    
                    if flag {
                        self.saveBtn.isEnabled = true
                        self.saveBtn.alpha = 1
                    } else {
                        self.saveBtn.isEnabled = false
                        self.saveBtn.alpha = 0.5
                    }
                    
                }

                

                
            }
            .store(in: &cancellables)
        
        
        

    }

}

extension EditFolderViewController {
    @objc
    private func tapDelete() {
        let alert = TipsAlertView(title: "确定删除该文件夹吗？", detail: "删除后，该文件夹及其包含的所有文件夹/文件都全部删除。", warning: "操作不可撤销，请谨慎操作！", sureBtnTitle: "确认删除")
        
        alert.sureCallback = { [weak self] in
            guard let self = self else { return }
            guard let id = self.type.folderId else { return }

            LoadingView.show()
            NetworkManager.shared.deleteFolder(id: id) { [weak self] _ in
                LoadingView.hide()
//                self?.showToast("删除成功".localizedString)
                alert.removeFromSuperview()
                
                
                let deleteTipsAlert = SingleTipsAlertView(detail: "正在删除文件夹,已为您后台运行,可返回列表查看。", sureBtnTitle: "确定".localizedString)
                deleteTipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    deleteTipsAlert.removeFromSuperview()
                    self.navigationController?.popViewController(animated: true)
                }
                SceneDelegate.shared.window?.addSubview(deleteTipsAlert)
                
            } failureCallback: { [weak self] code, err in
                LoadingView.hide()
                self?.showToast(err)
                alert.removeFromSuperview()
            }

        }

        SceneDelegate.shared.window?.addSubview(alert)
        
        
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 保存修改
    @objc
    private func save() {
        if type == .create {
            let name = nameCell.textField.text ?? ""
            let pool_name = selectedPool?.name ?? ""
            let partition_name = selectedPartition?.name ?? ""
            let is_encrypt = isSecureCell.selectView.selectedIndex == 0 ? 1 : 0
            let pwd = pwdCell1.textField.text ?? ""
            let confirmPwd = pwdCell2.textField.text ?? ""
            var mode: FolderModel.FolderMode = .shared
            if folderTypeCell.selectView.selectedIndex == 0 {
                mode = .private
            }
            
            showLoading()
            NetworkManager.shared.createFolder(name: name, pool_name: pool_name, partition_name: partition_name, is_encrypt: is_encrypt, pwd: pwd, confirm_pwd: confirmPwd, mode: mode, auth: members) { [weak self] _ in
                self?.showToast("保存成功".localizedString)
                self?.navigationController?.popViewController(animated: true)

            } failureCallback: { [weak self] code, err in
                self?.hideLoading()
                self?.showToast(err)
            }
        } else {
            guard let folder = folder else { return }
            let name = nameCell.textField.text ?? ""
            let pool_name = selectedPool?.name ?? ""
            let partition_name = selectedPartition?.name ?? ""
            var mode: FolderModel.FolderMode = .shared
            if folderTypeCell.selectView.selectedIndex == 0 {
                mode = .private
            }
            
            //如果修改了分区
            if pool_name != folder.pool_name || partition_name != folder.partition_name {
                let tipsAlert = TipsAlertView(title: "存储分区转移".localizedString, titleColor: .custom(.black_3f4663), detail: "\(name)存储分区从“\(folder.pool_name ?? "")-\(folder.partition_name ?? "")”改为“\(pool_name)-\(partition_name)”", detailColor: .custom(.black_3f4663), warning: "修改预计需要一段时间处理，且中途不可取消。确定要修改吗？".localizedString, warningColor: .custom(.red_fe0000), sureBtnTitle: "确定".localizedString)
                tipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    self.editFolder(id: folder.id, name: name, pool_name: pool_name, partition_name: partition_name, is_encrypt: folder.is_encrypt, mode: mode, auth: self.members)
                    tipsAlert.removeFromSuperview()
                }
                
                SceneDelegate.shared.window?.addSubview(tipsAlert)
                
            } else {
                editFolder(id: folder.id, name: name, pool_name: pool_name, partition_name: partition_name, is_encrypt: folder.is_encrypt, mode: mode, auth: members)
            }

            
            
        }
        

    }
    
    /// 编辑文件夹
    private func editFolder(id: Int, name: String, pool_name: String, partition_name: String, is_encrypt: Int, mode: FolderModel.FolderMode, auth: [User]) {
        showLoading()
        NetworkManager.shared.editFolder(id: id, name: name, pool_name: pool_name, partition_name: partition_name, is_encrypt: is_encrypt, mode: mode, auth: auth) { [weak self] _ in
            guard let self = self else { return }
            if pool_name != self.folder?.pool_name || partition_name != self.folder?.partition_name {
                //如果修改了分区
                let alert = SingleTipsAlertView(detail: "存储分区转移" + "\n\n" + "\(name)存储分区正在从“\(self.folder?.pool_name ?? "")-\(self.folder?.partition_name ?? "")”改为“\(pool_name)-\(partition_name)”,已为您后台运行,可返回列表查看。", sureBtnTitle: "确定".localizedString)
                alert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    alert.removeFromSuperview()
                    self.showToast("保存成功".localizedString)
                    self.navigationController?.popViewController(animated: true)
                }
                SceneDelegate.shared.window?.addSubview(alert)

            } else {
                self.showToast("保存成功".localizedString)
                self.navigationController?.popViewController(animated: true)
            }
            

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoading()
            if code == 20019 {
                //目标分区容量不足，不能迁移
                let errAlert = SingleTipsAlertView(detail: "存储分区修改失败".localizedString + "\n\n" + "分区容量不足！".localizedString, sureBtnTitle: "确定".localizedString)
                errAlert.sureCallback = {
                    errAlert.removeFromSuperview()
                }
                SceneDelegate.shared.window?.addSubview(errAlert)
                
            } else {
                self.showToast(err)
            }
            
        }
    }
    
    
    /// 获取文件夹详情
    private func getFolderDetail() {
        guard let id = type.folderId else { return }
        
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
            
            /// 2获取文件夹详情
            NetworkManager.shared.folderDetail(id: id) { [weak self] folder in
                guard let self = self else { return }
                sp.signal()
                self.hideLoading()
                self.folder = folder
                self.nameCell.textField.text = folder.name
                self.folderTypeCell.selectView.selectedIndex = folder.folderMode == .shared ? 1 : 0
                self.isSecureCell.selectView.selectedIndex = folder.is_encrypt == 0 ? 1 : 0
                self.selectedPool = self.storagePools.first(where: { $0.name == folder.pool_name })
                if let selectedPool = self.selectedPool {
                    self.selectedPartition = selectedPool.lv.first(where: { $0.name == folder.partition_name })
                    self.storageCell.detailLabel.text = "\(selectedPool.name)-\(self.selectedPartition?.name ?? "")"
                    self.storageCell.detailLabel.textColor = .custom(.black_3f4663)
                }

                if folder.folderMode == .private {
                    self.folderTypeCell.selectView.selectedIndex = 0
                    if folder.is_encrypt == 1 {
                        self.folderTypeCell.selectView.item1.alpha = 0.3
                        self.folderTypeCell.selectView.item1.label.text = "私人文件夹"
                        self.folderTypeCell.selectView.item2.isHidden = true
                        self.folderTypeCell.isUserInteractionEnabled = false
                    }

                    
                    self.isSecureCell.selectView.selectedIndex = 0
                    self.isSecureCell.selectView.item1.alpha = 0.3
                    self.isSecureCell.selectView.item1.label.text = folder.is_encrypt == 1 ? "是" : "否"
                    self.isSecureCell.selectView.item2.isHidden = true
                    self.isSecureCell.isUserInteractionEnabled = false
                } else {
                    self.folderTypeCell.selectView.selectedIndex = 1
                    
                    self.isSecureCell.selectView.selectedIndex = 0
                    self.isSecureCell.selectView.item1.alpha = 0.3
                    self.isSecureCell.selectView.item1.label.text = "否"
                    self.isSecureCell.selectView.item2.isHidden = true
                    self.isSecureCell.isUserInteractionEnabled = false
                }
                
                if let auths = folder.auth {
                    let users = auths.map { auth -> User in
                        let user = User()
                        user.user_id = auth.u_id
                        user.nickname = auth.nickname
                        user.icon_url = auth.face
                        user.read = auth.read
                        user.write = auth.write
                        user.deleted = auth.deleted
                        return user
                    }
                    
                    self.members = users
                }

                self.infoCellTypes = [.name, .storage, .folderType, .secure]
                self.memberTableView.reloadData()
                self.infoTableView.reloadData()
                
                
            } failureCallback: { [weak self] code, err in
                sp.signal()
                self?.hideLoading()
                self?.showToast(err)
                self?.navigationController?.popViewController(animated: true)
               
            }


        }


        

    }
    
    
    /// 获取存储池列表
    private func getStoragePools() {
        NetworkManager.shared.storagePoolList(page: 0, pageSize: 0) { [weak self] response in
            guard let self = self else { return }
            self.storagePools = response.list


        } failureCallback: { _, _ in }

    }
    

}


extension EditFolderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == infoTableView {
            return infoCellTypes.count
            
        } else {
            validatePublisher.send(())
            if members.count == 0 {
                memberTableView.addSubview(emptyMemberView)
                emptyMemberView.snp.makeConstraints {
                    $0.top.equalToSuperview()
                    $0.centerX.equalToSuperview()
                    $0.width.equalTo(Screen.screenWidth)
                    $0.height.equalTo(300.ztScaleValue)
                }
            } else {
                emptyMemberView.removeFromSuperview()
            }

            return members.count
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == infoTableView {
            switch infoCellTypes[indexPath.row] {
            case .name:
                return nameCell
            case .storage:
                return storageCell
            case .folderType:
                return folderTypeCell
            case .secure:
                return isSecureCell
            case .pwd1:
                return pwdCell1
            case .pwd2:
                return pwdCell2
            }
            
        } else {
            let cell = memberTableView.dequeueReusableCell(withIdentifier: EditFolderMemberCell.reusableIdentifier, for: indexPath) as! EditFolderMemberCell
            let member = members[indexPath.row]

            cell.member = member

            cell.editBtn.clickCallBack = { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                let alert = EditMemberAlert()
                let read = member.read == 1
                let write = member.write == 1
                let deleted = member.deleted == 1

                alert.set(member: member, read: read, write: write, delete: deleted)
                
                alert.sureCallback = { [weak self] read, write, delete in
                    guard let self = self else { return }
                    member.read = read ? 1 : 0
                    member.write = write ? 1 : 0
                    member.deleted = delete ? 1 : 0
                    self.memberTableView.reloadData()
                    alert.removeFromSuperview()
                }

                SceneDelegate.shared.window?.addSubview(alert)

            }
            
            cell.deleteBtn.clickCallBack = { [weak self] _ in
                guard let self = self else { return }
                self.members.remove(at: indexPath.row)
                self.memberTableView.reloadData()
                self.validatePublisher.send()
            }

            return cell
            
        }

        
        
    }
    
    
    
    
}


extension EditFolderViewController {
    enum InfoCellType {
        case name
        case storage
        case folderType
        case secure
        case pwd1
        case pwd2
    }
}
