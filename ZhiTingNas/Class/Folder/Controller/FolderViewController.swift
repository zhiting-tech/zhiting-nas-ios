//
//  FolderViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/27.
//

import UIKit
import TZImagePickerController

class FolderViewController: BaseViewController {
    
    
    private lazy var headerView = FolderDetailHeader(currentFileName: currentPaths.last ?? "").then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var emptyView = FileEmptyView()
    
    //密码输入框
    private var tipsTestFieldAlert: TipsTextFieldAlertView?
    
    //PathCollectionView
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal//水平方向滚动
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
    }
    
    lazy var pathCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.isScrollEnabled = true
        $0.register(PathCell.self, forCellWithReuseIdentifier: PathCell.reusableIdentifier)
    }
    
    var currentPath = ""
    var currentPaths = [String]()
    
    private var isGetAllData = false//是否已获取服务器所有数据
    //用于判断是否从共享进入，初始路径
    var isFromShareFile = false
    var shareBaseFile = FileModel()
    //存储密钥的key
    var rootPasswordKey = ""
    //加密的根目录文件
    var encrytRootFile = FileModel()
    //是否有写入权限
    var isWriteRoot = true
    
    
    private var currentDatas = [FileModel]()
    private var seletedFiles = [FileModel]()//选中的文件
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderTableViewCell.reusableIdentifier)
        
    }
    
    lazy var encrytImgView = ImageView().then {
        $0.image = .assets(.encrypt_bg_icon)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var funtionTabbarView = FunctionTabbarView().then {
        $0.backgroundColor = .custom(.blue_427aed)
    }
    private var funtionTabbarIsShow = false
    
    private var myFileDetailView = FileDetailAlertView(title: "文件详情")
    private var setNameView: SetNameAlertView?
    private var  updateFileView = UpdateFileAlertView(title: "上传文件")
    /// 其他文件上传选择器
    private lazy var documentPicker = DocumentPicker(presentationController: self, delegate: self)
    
    var transitionUtil = FolderTransitionUtil()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
        
        // MARK: - updateFileView
        updateFileView.selectCallback = { [weak self] index in
            guard let self = self else { return }
            if index == 0 {
                self.presentTZPicker(allowVideo: true)
            } else if index == 1 {
                self.presentTZPicker(allowVideo: false)
            } else if index == 2 {
                self.documentPicker.displayPicker()
            }
            
        }
        
        // MARK: - 文件共享
        funtionTabbarView.shareBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击共享到")
            let shareVC = FileShareController()
            shareVC.fileDatas = self.seletedFiles
            self.navigationController?.pushViewController(shareVC, animated: true)
            self.hideFunctionTabbarView()
        }
        // MARK: - 文件下载
        funtionTabbarView.downloadBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击下载")
            if NetworkStateManager.shared.networkState == .reachable(type: .cellular) && !UserManager.shared.allowCellular {
                NormalAlertView.show(title: "提示", message: "当前正在使用移动流量，使用会消耗较多流量，是否继续?", leftTap: "取消", rightTap: "继续", clickCallback: { [weak self] tap in
                    guard let self = self else { return }
                    switch tap {
                    case 0:
                        print("取消")
                    case 1:
                        print("继续")
                        self.seletedFiles.forEach {
                            if $0.type == 1 { /// 下载文件
                                GoFileManager.shared.download(path: $0.path, thumbnailUrl: $0.thumbnail_url)
                            } else { /// 下载目录
                                GoFileManager.shared.downloadDir(requestUrl: "/wangpan/api", filePath: $0.path)
                            }
                            
                        }
                        
                        SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                        
                        self.hideFunctionTabbarView()
                        self.tableView.reloadData()
                        
                    default:
                        break
                    }
                }, removeWithSure: false)
                
            } else {
                self.seletedFiles.forEach {
                    if $0.type == 1 { /// 下载文件
                        GoFileManager.shared.download(path: $0.path, thumbnailUrl: $0.thumbnail_url)
                    } else { /// 下载目录
                        GoFileManager.shared.downloadDir(requestUrl: "/wangpan/api", filePath: $0.path)
                    }
                    
                }
                
                SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                
                self.hideFunctionTabbarView()
                self.tableView.reloadData()
            }
            
        }
        // MARK: - 文件移动
        funtionTabbarView.moveBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
            print("点击移动到")
            self.pushToMoveFolder(type: .move)
        }
        // MARK: - 文件复制
        funtionTabbarView.copyBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            
            print("点击复制到")
            self.pushToMoveFolder(type: .copy)
        }
        // MARK: - 文件重命名
        funtionTabbarView.resetNameBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击重命名")
            guard
                let file = self.seletedFiles.first,
                let row = self.currentDatas.firstIndex(where: { $0.id == file.id })
            else {
                return
            }
            
            let indexPath = IndexPath(row: row, section: 0)
            self.showResetNameView(name: file.name, isFile: file.type == 1)
            self.setNameView?.setNameCallback = { name in
                if name.isEmpty {
                    SceneDelegate.shared.window?.makeToast("请输入名称".localizedString)
                    return
                }
                if let originalExtension = file.name.components(separatedBy: ".").last,
                   let newExtension = name.components(separatedBy: ".").last
                {
                    if originalExtension != newExtension && file.type == 1 {
                        let alertViewController = UIAlertController(title: "", message: "更改文件类型可能导致文件不可用,是否继续?", preferredStyle: .alert)
                        alertViewController.addAction(UIAlertAction(title: "取消".localizedString, style: .cancel, handler: nil))
                        alertViewController.addAction(UIAlertAction(title: "确定".localizedString, style: .default, handler: { [weak self] _ in
                            guard let self = self else { return }
                            LoadingView.show()
                            
                            NetworkManager.shared.renameFile(path: file.path, name: name) { [weak self] response in
                                guard let self = self else { return }
                                let newPath = file.path.replacingOccurrences(of: file.name, with: name)
                                file.path = newPath
                                file.name = name
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                self.setNameView?.removeFromSuperview()
                                self.hideFunctionTabbarView()
                                LoadingView.hide()
                                SceneDelegate.shared.window?.makeToast("重命名成功".localizedString)
                            } failureCallback: { code, err in
                                SceneDelegate.shared.window?.makeToast(err)
                                LoadingView.hide()
                            }
                        }))
                        self.present(alertViewController, animated: true, completion: nil)
                        return
                    }
                }
                
                LoadingView.show()
                
                NetworkManager.shared.renameFile(path: file.path, name: name) { [weak self] response in
                    guard let self = self else { return }
                    let newPath = file.path.replacingOccurrences(of: file.name, with: name)
                    file.path = newPath
                    file.name = name
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.setNameView?.removeFromSuperview()
                    self.hideFunctionTabbarView()
                    LoadingView.hide()
                    SceneDelegate.shared.window?.makeToast("重命名成功".localizedString)
                } failureCallback: { code, err in
                    SceneDelegate.shared.window?.makeToast(err)
                    LoadingView.hide()
                }
                
            }
            
        }
        
        funtionTabbarView.deleteBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击删除")
            let paths = self.seletedFiles.map(\.path)
            var indexPaths = [IndexPath]()
            for (idx, data) in self.currentDatas.enumerated() {
                if self.seletedFiles.contains(where: {$0.id == data.id}) {
                    indexPaths.append(.init(row: idx, section: 0))
                }
            }
            
            let tipsAlert = TipsAlertView(title: "", detail: String(format: "共%d个文件/文件夹，确定删除吗？", paths.count), warning: "文件删除后不可恢复", sureBtnTitle: "确定")
            tipsAlert.sureCallback = { [weak self] in
                guard let self = self else { return }
                tipsAlert.sureBtn.buttonState = .waiting
                NetworkManager.shared.deleteFile(paths: paths) { [weak self] response in
                    guard let self = self else { return }
                    self.myFileDetailView.removeFromSuperview()
                    tipsAlert.removeFromSuperview()
                    self.tableView.beginUpdates()
                    self.currentDatas.removeAll(where: { self.seletedFiles.map(\.id).contains($0.id) })
                    self.tableView.deleteRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                    self.hideFunctionTabbarView()
                    SceneDelegate.shared.window?.makeToast("删除成功".localizedString)
                    
                } failureCallback: { code, err in
                    tipsAlert.sureBtn.buttonState = .normal
                    SceneDelegate.shared.window?.makeToast(err)
                }
            }
            SceneDelegate.shared.window?.addSubview(tipsAlert)
        }
        
        //是否为加密文件夹内
        encrytImgView.isHidden = (rootPasswordKey == "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        pathCollectionView.scrollToItem(at: IndexPath(item: currentPaths.count - 1, section: 0), at: .right, animated: true)
        
        let transferingItemsCount = GoFileManager.shared.getTotalonGoingCount()
        self.headerView.transferListBtn.setUpNumber(value: transferingItemsCount)
        
    }
    
    override func setupViews() {
        view.addSubview(headerView)
        if isWriteRoot {
            headerView.setBtns(btns: [.upload,.newFolder,.transfer])
        }else{
            headerView.setBtns(btns: [.transfer])
        }
        headerView.actionCallback = { [weak self] tag in
            guard let self = self else { return }
            switch tag {
            case 0:
                self.currentPaths.removeLast()
                self.navigationController?.popViewController(animated: true)
            case 1:
                print("点击传输列表")
                let transferVC = TransferViewController()
                self.navigationController?.pushViewController(transferVC, animated: true)
            case 2:
                print("新建文件夹")
                self.showCreatNewFolderView()
                self.setNameView?.setNameCallback = { name in
                    if name.isEmpty {
                        SceneDelegate.shared.window?.makeToast("请输入名称".localizedString)
                        return
                    }
                    LoadingView.show()
                    
                    let pwdJsonStr:String = UserDefaults.standard.value(forKey: self.rootPasswordKey) as? String ?? ""
                    let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
                    
                    NetworkManager.shared.createDirectory(path: self.currentPath, name: name, pwd: pwdModel?.password ?? "") { [weak self] resposne in
                        LoadingView.hide()
                        guard let self = self else { return }
                        self.reload()
                        self.setNameView?.removeFromSuperview()
                        SceneDelegate.shared.window?.makeToast("新建文件夹成功".localizedString)
                    } failureCallback: { code, err in
                        LoadingView.hide()
                        SceneDelegate.shared.window?.makeToast(err)
                    }
                    
                }
            case 3:
                print("上传文件")
                self.showUpdateFileView()
            default:
                break
            }
        }
        view.addSubview(pathCollectionView)
        view.addSubview(encrytImgView)
        view.addSubview(tableView)
        let header = GIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reload))
        tableView.mj_footer = MJRefreshBackNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadNextData))
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        
        pathCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(30))
        }
        
        encrytImgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(200))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(pathCollectionView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setupSubscriptions() {
        GoFileManager.shared.taskCountChangePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                let transferingItemsCount = GoFileManager.shared.getTotalonGoingCount()
                DispatchQueue.main.async {
                    self.headerView.transferListBtn.setUpNumber(value: transferingItemsCount)
                }
            }
            .store(in: &cancellables)
        
    }
    
    @objc private func reload(){
        hideFunctionTabbarView()
        
        let transferingItemsCount = GoFileManager.shared.getTotalonGoingCount()
        self.headerView.transferListBtn.setUpNumber(value: transferingItemsCount)
        
        loadDatas(isReload: true)
    }
    
    
    @objc private func loadNextData() {
        if isGetAllData {
            return
        }
        loadDatas(isReload: false)
    }
    
    private func loadDatas(isReload:Bool){
        if isReload {//下拉刷新
            showLoading()
            currentDatas.removeAll()
            tableView.reloadData()
            isGetAllData = false
            tableView.mj_header?.endRefreshing()
            tableView.mj_footer?.resetNoMoreData()
            tableView.mj_footer?.endRefreshing()
        }
        
        //存储的密码对象
        let pwdJsonStr:String = UserDefaults.standard.value(forKey: rootPasswordKey) as? String ?? ""
        let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
        
        let page = (currentDatas.count / 30) + 1
        
        NetworkManager.shared.fileList(path: currentPath, page: page, page_size: 30, pwd: pwdModel?.password ?? "") { [weak self] response in
            guard let self = self else { return }
            
            self.hideLoading()
            
            let datas = response.list.filter({$0.read != 0})
            
            if isReload {//下拉刷新 or 首次加载数据
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
                //删选没有可读权限的文件
                
                if datas.count == 0 {
                    //空数据展示页面
                    self.tableView.addSubview(self.emptyView)
                    self.emptyView.snp.makeConstraints {
                        $0.center.equalToSuperview()
                        $0.width.equalTo(Screen.screenWidth)
                        $0.height.equalTo(ZTScaleValue(110))
                    }
                    self.tableView.mj_footer?.isHidden = true
                    self.tableView.reloadData()
                    self.encrytImgView.isHidden = true
                }else{
                    self.emptyView.removeFromSuperview()
                    self.currentDatas = datas
                    if response.list.count < 30 {
                        self.tableView.mj_footer?.isHidden = true
                    }else{
                        self.tableView.mj_footer?.isHidden = false
                    }
                    self.tableView.reloadData()
                    self.encrytImgView.isHidden = (self.rootPasswordKey == "")
                }
            } else {//上拉加载更多数据
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
                if !response.pager.has_more {//已无数据
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    self.isGetAllData = true
                    return
                }
                self.isGetAllData = false
                self.currentDatas += datas
                self.tableView.reloadData()
            }
        } failureCallback: {[weak self] code, err in
            guard let self = self else { return }
            self.hideLoading()
            if self.currentDatas.count == 0 {
                self.tableView.addSubview(self.emptyView)
                self.emptyView.snp.makeConstraints {
                    $0.center.equalToSuperview()
                    $0.width.equalTo(Screen.screenWidth)
                    $0.height.equalTo(ZTScaleValue(110))
                }
            }else{
                self.emptyView.removeFromSuperview()
            }
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.showToast("\(err)")
            if code == 20009 {//密码错误
                UserDefaults.standard.removeObject(forKey: self.rootPasswordKey)
                //回到首页
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideAllFuntionView()
    }
    
    private func showUpdateFileView(){
        if NetworkStateManager.shared.networkState == .reachable(type: .cellular) && !UserManager.shared.allowCellular {
            NormalAlertView.show(title: "提示", message: "当前正在使用移动流量，上传会消耗较多流量，是否继续?", leftTap: "取消", rightTap: "继续", clickCallback: { [weak self] tap in
                guard let self = self else { return }
                switch tap {
                case 0:
                    print("取消")
                case 1:
                    print("继续")
                    SceneDelegate.shared.window?.addSubview(self.updateFileView)
                    self.updateFileView.snp.makeConstraints {
                        $0.top.equalTo(self.headerView.snp.bottom)
                        $0.left.right.bottom.equalToSuperview()
                    }
                    SceneDelegate.shared.window?.bringSubviewToFront(self.updateFileView)
                    
                default:
                    break
                }
            }, removeWithSure: false)
            
        } else {
            SceneDelegate.shared.window?.addSubview(updateFileView)
            updateFileView.snp.makeConstraints {
                $0.top.equalTo(headerView.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            SceneDelegate.shared.window?.bringSubviewToFront(updateFileView)
        }
        
    }
}

extension FolderViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPaths.count
    }
    
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.reusableIdentifier, for: indexPath) as! PathCell
        cell.titleLabel.text = currentPaths[indexPath.item]
        if indexPath.item == currentPaths.count - 1 {
            cell.arrowImgview.isHidden = true
        }else{
            cell.arrowImgview.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //点击栏目回到对应文件路径
        if indexPath.item == 0 {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        if indexPath.item == currentPaths.count - 1 {
            return
        }
        
        if (self.navigationController?.viewControllers.count)! >= indexPath.item - 1 {
            guard let vc = self.navigationController?.viewControllers[indexPath.item - 1] else { return }
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FolderViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.reusableIdentifier, for: indexPath) as! FolderTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let file = currentDatas[indexPath.row]
        cell.setModel(currentModel: file)
        cell.selectBtn.tag = indexPath.row
        //只有根目录才能有加密图标
        cell.encryptImgView.isHidden = true
        
        cell.selectBtn.clickCallBack = { [weak self] sender in
            guard let self = self else {
                return
            }
            
            sender.isSelected = !sender.isSelected
            let file: FileModel = self.currentDatas[sender.tag]
            file.isSelected = !file.isSelected
            
            if sender.isSelected {//选中
                self.seletedFiles.append(file)//添加选中目标
            }else{
                //删除取消选中对象
                self.seletedFiles.removeAll(where: { file.name == $0.name })
            }
            
            
            if self.seletedFiles.count > 0 {
                if !self.funtionTabbarIsShow {
                    self.showFunctionTabbarView()
                }
                
                //权限判断
                
                if self.seletedFiles.filter({$0.write == 0}).count > 0 {//没有写入权限
                    self.funtionTabbarView.setShareBtnIsEnabled(isEnabled: false)
                    self.funtionTabbarView.setResetNameBtnIsEnabled(isEnabled: false)
                    self.funtionTabbarView.setDownloadBtnIsEnabled(isEnabled: false)
                }else{
                    //选择均为文件夹时才能显示共享按钮
                    var isShowShare = true
                    for file in self.seletedFiles {
                        if file.type != 0 || file.is_encrypt == 1{//存在非文件夹或者加密文件情况下均不能共享
                            isShowShare = false
                        }
                    }
                    self.funtionTabbarView.setShareBtnIsEnabled(isEnabled: isShowShare)
                    self.funtionTabbarView.setResetNameBtnIsEnabled(isEnabled: self.seletedFiles.count == 1)
                    self.funtionTabbarView.setDownloadBtnIsEnabled(isEnabled: true)
                }
                
                if self.seletedFiles.filter({$0.deleted == 0}).count > 0 {//没有删权限
                    self.funtionTabbarView.setMoveBtnIsEnabled(isEnabled: false)
                    self.funtionTabbarView.setDeleteBtnIsEnabled(isEnabled: false)
                }else{
                    self.funtionTabbarView.setMoveBtnIsEnabled(isEnabled: true)
                    self.funtionTabbarView.setDeleteBtnIsEnabled(isEnabled: true)
                }
                
            }else{
                self.hideFunctionTabbarView()
            }
        }
        return cell
    }
    
    private func pushToFolder(isNeedPwd:Bool,file:FileModel){
        if isNeedPwd {
            self.tipsTestFieldAlert = TipsTextFieldAlertView.show(message: "请输入密码", sureCallback: {[weak self] pwd in
                guard let self = self else {return}
                print("密码是\(pwd)")
                NetworkManager.shared.decryptFolder(name: file.path, password: pwd) {[weak self] response in
                    guard let self = self else {return}
                    //更新时间和密码
                    let pwdModel = PasswordModel()
                    pwdModel.password = pwd
                    //当前时间
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    pwdModel.saveTime = dateFormatter.string(from: Date())
                    UserDefaults.standard.setValue(pwdModel.toJSONString(prettyPrint:true), forKey: self.rootPasswordKey)
                    
                    //解密成功，进入文件夹
                    let vc = FolderViewController()
                    vc.currentPath = file.path
                    vc.isFromShareFile = self.isFromShareFile
                    vc.shareBaseFile = self.shareBaseFile
                    vc.encrytRootFile = self.encrytRootFile
                    vc.rootPasswordKey = self.rootPasswordKey
                    vc.isWriteRoot = (file.write == 1)
                    
                    let paths = self.currentPaths + [file.name]
                    vc.currentPaths = paths
                    self.navigationController?.pushViewController(vc, animated: true)
                } failureCallback: { code, err in
                    //密码验证失败
                    self.showToast(err)
                }
            })
        }else{
            //无需输入密码
            let vc = FolderViewController()
            vc.currentPath = file.path
            vc.isFromShareFile = isFromShareFile
            vc.shareBaseFile = shareBaseFile
            vc.rootPasswordKey = self.rootPasswordKey
            vc.encrytRootFile = encrytRootFile
            let paths = currentPaths + [file.name]
            vc.currentPaths = paths
            vc.isWriteRoot = (file.write == 1)
            self.navigationController?.pushViewController(vc, animated: true)        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击cell
        
        print("点击cell")
        let file = currentDatas[indexPath.row]
        if file.type == 0 {//文件夹
            //文件夹是否加密
            if file.is_encrypt == 1 {
                //加密文件，判断是否存在key
                //存储的密码对象
                let pwdJsonStr:String = UserDefaults.standard.value(forKey: self.rootPasswordKey) as? String ?? ""
                let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
                
                if pwdModel != nil {
                    //计算时间差
                    let timeTemp = TimeTool.TimeInterval(FromTime: pwdModel!.saveTime)
                    if timeTemp > 72 {//大于72小时
                        //重新输入密码
                        pushToFolder(isNeedPwd: true, file: file)
                    }else{
                        //无需输入密码
                        pushToFolder(isNeedPwd: false, file: file)
                    }
                }else{
                    //需要重新输入密码
                    pushToFolder(isNeedPwd: true, file: file)
                }
                
            }else{
                //非加密，直接请求下一个页面
                pushToFolder(isNeedPwd: false, file: file)
            }
            return
        }
        switch ZTCTool.resourceTypeBy(fileName: file.name) {
        case .ppt,.pdf,.txt,.excel,.document,.music,.picture,.video:
            myFileDetailView.setCurrentFileModel(file: file, types: [.download, .move, .copy, .preview, .rename, .delete])
            
        default:
            myFileDetailView.setCurrentFileModel(file: file, types: [.download, .move, .copy, .rename, .delete])
        }
        myFileDetailView.selectCallback = {[weak self] type in
            guard let self = self else {
                return
            }
            
            switch type {
            case .preview:
                
                guard let fileUrl = URL(string: "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(file.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? file.path)") else {
                    return
                }
                //检查是否大于10m
                if file.size > 10*1024*1024 {
                    NormalAlertView.show(title: "温馨提示", message: "该文件过大，建议下载本地后进行查看", leftTap: "查看", rightTap: "下载", clickCallback: { tap in
                        switch tap {
                        case 0://查看
                            //判断类型
                            switch ZTCTool.resourceTypeBy(fileName: file.name) {
                            case .video:
                                let playerVC = MultimediaController(type: .video(title: file.name, url: fileUrl))
                                playerVC.modalPresentationStyle = .fullScreen
                                playerVC.transitioningDelegate = self.transitionUtil
                                self.present(playerVC, animated: true, completion: nil)
                                
                            case .music:
                                let playerVC = MultimediaController(type: .music(title: file.name, url: fileUrl))
                                playerVC.modalPresentationStyle = .fullScreen
                                playerVC.transitioningDelegate = self.transitionUtil
                                self.present(playerVC, animated: true, completion: nil)
                                
                            case .picture:
                                //获取图片集，以及当前第几个
                                let picSet = self.currentDatas.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                                let index = picSet.firstIndex(where: {$0.name == file.name}) ?? 0
                                let picStringSet = picSet.map({ fileModel -> String in
                                    guard let url = URL(string: "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(fileModel.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileModel.path)") else { return "" }
                                    
                                    return url.absoluteString
                                })
                                let titleSet = picSet.map(\.name)
                                
                                let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                                playerVC.modalPresentationStyle = .fullScreen
                                playerVC.transitioningDelegate = self.transitionUtil
                                self.present(playerVC, animated: true, completion: nil)
                                
                            case .document,.excel,.txt,.pdf,.ppt:
                                let playerVC = MultimediaController(type: .document(title: file.name, url: fileUrl))
                                playerVC.modalPresentationStyle = .fullScreen
                                playerVC.transitioningDelegate = self.transitionUtil
                                self.present(playerVC, animated: true, completion: nil)
                            default:
                                break
                            }
                            self.myFileDetailView.removeFromSuperview()
                        case 1://下载
                            if NetworkStateManager.shared.networkState == .reachable(type: .cellular) && !UserManager.shared.allowCellular {
                                NormalAlertView.show(title: "提示", message: "当前正在使用移动流量，使用会消耗较多流量，是否继续?", leftTap: "取消", rightTap: "继续", clickCallback: { [weak self] tap in
                                    guard let self = self else { return }
                                    switch tap {
                                    case 0:
                                        print("取消")
                                    case 1:
                                        print("继续")
                                        GoFileManager.shared.download(path: file.path, thumbnailUrl: file.thumbnail_url)
                                        SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                                        self.myFileDetailView.removeFromSuperview()
                                        self.hideFunctionTabbarView()
                                        self.tableView.reloadData()
                                        
                                    default:
                                        break
                                    }
                                }, removeWithSure: false)
                                
                            } else {
                                GoFileManager.shared.download(path: file.path, thumbnailUrl: file.thumbnail_url)
                                SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                                self.myFileDetailView.removeFromSuperview()
                                self.hideFunctionTabbarView()
                                self.tableView.reloadData()
                            }
                            
                        default:
                            break
                        }
                    }, removeWithSure: true)
                }else{
                    //判断类型
                    switch ZTCTool.resourceTypeBy(fileName: file.name) {
                    case .video:
                        let playerVC = MultimediaController(type: .video(title: file.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                        
                    case .music:
                        let playerVC = MultimediaController(type: .music(title: file.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                        
                    case .picture:
                        //获取图片集，以及当前第几个
                        let picSet = self.currentDatas.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                        let index = picSet.firstIndex(where: {$0.name == file.name}) ?? 0
                        let picStringSet = picSet.map({ fileModel -> String in
                            guard let url = URL(string: "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(fileModel.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileModel.path)") else { return "" }
                            
                            return url.absoluteString
                        })
                        let titleSet = picSet.map(\.name)
                        
                        let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                        
                    case .document,.excel,.txt,.pdf,.ppt:
                        let playerVC = MultimediaController(type: .document(title: file.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                        
                    default:
                        break
                    }
                }
                
            case .open:
                print("点击其他应用打开")
                
            case .download:
                print("点击下载")
                if NetworkStateManager.shared.networkState == .reachable(type: .cellular) && !UserManager.shared.allowCellular {
                    NormalAlertView.show(title: "提示", message: "当前正在使用移动流量，使用会消耗较多流量，是否继续?", leftTap: "取消", rightTap: "继续", clickCallback: { [weak self] tap in
                        guard let self = self else { return }
                        switch tap {
                        case 0:
                            print("取消")
                        case 1:
                            print("继续")
                            GoFileManager.shared.download(path: file.path, thumbnailUrl: file.thumbnail_url)
                            SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                            self.myFileDetailView.removeFromSuperview()
                            self.hideFunctionTabbarView()
                            self.tableView.reloadData()
                            
                        default:
                            break
                        }
                    }, removeWithSure: false)
                    
                } else {
                    GoFileManager.shared.download(path: file.path, thumbnailUrl: file.thumbnail_url)
                    SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                    self.myFileDetailView.removeFromSuperview()
                    self.hideFunctionTabbarView()
                    self.tableView.reloadData()
                }
                
                
            case .move:
                print("点击移动到")
                self.seletedFiles.append(file)
                self.myFileDetailView.removeFromSuperview()
                self.pushToMoveFolder(type: .move)
            case .copy:
                print("点击复制到")
                self.seletedFiles.append(file)
                self.myFileDetailView.removeFromSuperview()
                self.pushToMoveFolder(type: .copy)
            case .rename:
                print("点击重命名")
                self.myFileDetailView.removeFromSuperview()
                self.showResetNameView(name: file.name, isFile: file.type == 1)
                self.setNameView?.setNameCallback = { name in
                    if name.isEmpty {
                        SceneDelegate.shared.window?.makeToast("请输入名称".localizedString)
                        return
                    }
                    if let originalExtension = file.name.components(separatedBy: ".").last,
                       let newExtension = name.components(separatedBy: ".").last
                    {
                        if originalExtension != newExtension && file.type == 1 {
                            let alertViewController = UIAlertController(title: "", message: "更改文件类型可能导致文件不可用,是否继续?", preferredStyle: .alert)
                            alertViewController.addAction(UIAlertAction(title: "取消".localizedString, style: .cancel, handler: nil))
                            alertViewController.addAction(UIAlertAction(title: "确定".localizedString, style: .default, handler: { [weak self] _ in
                                guard let self = self else { return }
                                LoadingView.show()
                                let pwdJsonStr:String = UserDefaults.standard.value(forKey: self.rootPasswordKey) as? String ?? ""
                                let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
                                
                                NetworkManager.shared.renameFile(path: file.path, name: pwdModel?.password ?? "") { [weak self] response in
                                    guard let self = self else { return }
                                    let newPath = file.path.replacingOccurrences(of: file.name, with: name)
                                    file.path = newPath
                                    file.name = name
                                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                                    self.setNameView?.removeFromSuperview()
                                    self.hideFunctionTabbarView()
                                    LoadingView.hide()
                                    SceneDelegate.shared.window?.makeToast("重命名成功".localizedString)
                                } failureCallback: { code, err in
                                    SceneDelegate.shared.window?.makeToast(err)
                                    LoadingView.hide()
                                }
                            }))
                            self.present(alertViewController, animated: true, completion: nil)
                            return
                        }
                    }
                    
                    LoadingView.show()
                    
                    NetworkManager.shared.renameFile(path: file.path, name: name) { [weak self] response in
                        guard let self = self else { return }
                        let newPath = file.path.replacingOccurrences(of: file.name, with: name)
                        file.path = newPath
                        file.name = name
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self.setNameView?.removeFromSuperview()
                        self.hideFunctionTabbarView()
                        LoadingView.hide()
                        SceneDelegate.shared.window?.makeToast("重命名成功".localizedString)
                    } failureCallback: { code, err in
                        SceneDelegate.shared.window?.makeToast(err)
                        LoadingView.hide()
                    }
                    
                    
                    
                }
            case .delete:
                print("点击删除")
                let tipsAlert = TipsAlertView(title: "", detail: "共1个文件/文件夹，确定删除吗？", warning: "文件删除后不可恢复", sureBtnTitle: "确定")
                tipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    
                    tipsAlert.sureBtn.buttonState = .waiting
                    NetworkManager.shared.deleteFile(paths: [file.path]) { [weak self] response in
                        guard let self = self else { return }
                        self.myFileDetailView.removeFromSuperview()
                        SceneDelegate.shared.window?.makeToast("删除成功".localizedString)
                        tipsAlert.removeFromSuperview()
                        
                        self.tableView.beginUpdates()
                        self.currentDatas.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                        self.hideFunctionTabbarView()
                        
                    } failureCallback: { code, err in
                        tipsAlert.sureBtn.buttonState = .normal
                        SceneDelegate.shared.window?.makeToast(err)
                        LoadingView.hide()
                    }
                }
                SceneDelegate.shared.window?.addSubview(tipsAlert)
                
                
            }
        }
        showFileDetailView()
    }
}

extension FolderViewController {
    private func showFunctionTabbarView() {
        funtionTabbarView.removeFromSuperview()
        funtionTabbarView.tag = 9
        SceneDelegate.shared.window?.addSubview(funtionTabbarView)
        funtionTabbarIsShow = true
        funtionTabbarView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(Screen.tabbarHeight)
        }
        tableView.snp.remakeConstraints {
            $0.top.equalTo(pathCollectionView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(funtionTabbarView.snp.top)
        }
    }
    
    private func hideFunctionTabbarView() {
        funtionTabbarIsShow = false
        seletedFiles.removeAll()
        for (_,file) in currentDatas.enumerated() {
            file.isSelected = false
        }
        funtionTabbarView.removeFromSuperview()
        tableView.snp.remakeConstraints {
            $0.top.equalTo(pathCollectionView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func showFileDetailView(){
        SceneDelegate.shared.window?.addSubview(myFileDetailView)
    }
    
    private func showResetNameView(name:String, isFile: Bool){
        setNameView = SetNameAlertView(setNameType: .resetName(isFile: isFile), currentName: name)
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }
    
    private func showCreatNewFolderView(){
        setNameView = SetNameAlertView(setNameType: .creatFile, currentName: "")
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }
    
    private func hideAllFuntionView(){
        hideFunctionTabbarView()
        myFileDetailView.removeFromSuperview()
        setNameView?.removeFromSuperview()
        tableView.reloadData()
    }
    
    private func pushToMoveFolder(type:MoveType){
        //判断是否在共享文件内
        if !isFromShareFile {
            //加密文件内移动和复制仅对加密文件的根目录内可操作，只进不出
            let file = self.seletedFiles.first
            if file?.is_encrypt == 1 {//加密文件
                let vc = ChangeFolderPlaceController()
                vc.type = type
                vc.isRootPath = false
                vc.is_encryt = true
                vc.rootPasswordKey = rootPasswordKey
                vc.encrytRootFile = encrytRootFile
                vc.currentPath = encrytRootFile.path
                vc.currentPaths = [encrytRootFile.name]
                vc.seletedFiles = self.seletedFiles
                vc.refreshCallback = { [weak self] ids in
                    guard let self = self else { return }
                    let indexPaths = ids.compactMap { id -> IndexPath? in
                        if let row = self.currentDatas.firstIndex(where: { $0.id == id }) {
                            return IndexPath(row: row, section: 0)
                        }
                        return nil
                    }
                    self.tableView.beginUpdates()
                    self.currentDatas.removeAll(where: { ids.contains($0.id) })
                    self.tableView.deleteRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                    self.hideFunctionTabbarView()
                }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            }else{//非加密文件
                let vc = ChangeFolderPlaceController()
                vc.type = type
                vc.isRootPath = true
                vc.is_encryt = false
                vc.currentPaths = ["根目录"]
                vc.seletedFiles = self.seletedFiles
                vc.refreshCallback = { [weak self] ids in
                    guard let self = self else { return }
                    let indexPaths = ids.compactMap { id -> IndexPath? in
                        if let row = self.currentDatas.firstIndex(where: { $0.id == id }) {
                            return IndexPath(row: row, section: 0)
                        }
                        return nil
                    }
                    self.tableView.beginUpdates()
                    self.currentDatas.removeAll(where: { ids.contains($0.id) })
                    self.tableView.deleteRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                    self.hideFunctionTabbarView()
                }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            //共享文件内移动文件仅对子级文件可操作
            let vc = ChangeFolderPlaceController()
            vc.type = type
            if type == .copy {
                vc.isRootPath = true
                vc.currentPaths = ["根目录"]
            }else{
                vc.isRootPath = shareBaseFile.from_user.isEmpty
                vc.currentPaths = shareBaseFile.from_user.isEmpty ? ["根目录"] : [shareBaseFile.name]
            }
            vc.currentPath = shareBaseFile.path
            vc.seletedFiles = self.seletedFiles
            vc.refreshCallback = { [weak self] ids in
                guard let self = self else { return }
                let indexPaths = ids.compactMap { id -> IndexPath? in
                    if let row = self.currentDatas.firstIndex(where: { $0.id == id }) {
                        return IndexPath(row: row, section: 0)
                    }
                    return nil
                }
                self.tableView.beginUpdates()
                self.currentDatas.removeAll(where: { ids.contains($0.id) })
                self.tableView.deleteRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
                self.hideFunctionTabbarView()
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        self.hideAllFuntionView()
    }
    
}


// MARK: - upload image & video
extension FolderViewController: TZImagePickerControllerDelegate {
    private func presentTZPicker(allowVideo: Bool) {
        guard let imagePickerVC = FixedTZImagePickerController(maxImagesCount: 9, delegate: self) else { return }
        imagePickerVC.naviBgColor = .custom(.white_ffffff)
        imagePickerVC.naviTitleColor = .custom(.black_3f4663)
        imagePickerVC.barItemTextColor = .custom(.blue_2da3f6)
        imagePickerVC.iconThemeColor = .custom(.blue_2da3f6)
        imagePickerVC.oKButtonTitleColorNormal = .custom(.blue_2da3f6)
        imagePickerVC.allowPickingVideo = allowVideo ? true : false
        imagePickerVC.allowPickingImage = allowVideo ? false : true
        imagePickerVC.allowPickingMultipleVideo = true
        imagePickerVC.allowPickingOriginalPhoto = allowVideo ? false : true
        imagePickerVC.photoOriginSelImage = .assets(.fileSelected_selected)
        imagePickerVC.photoSelImage = .assets(.fileSelected_selected)
        present(imagePickerVC, animated: true, completion: nil)
        
    }
    
    /// 选择完上传的图片或视频
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        if picker.allowPickingVideo {
            let options: PHVideoRequestOptions = PHVideoRequestOptions ()
            options.deliveryMode = .highQualityFormat
            options.version = .original
            
            assets.forEach { asset in
                guard let phAsset = asset as? PHAsset else { return }
                TZImageManager.default().requestVideoURL(with: phAsset) { [weak self] url in
                    guard let self = self, let url = url else { return }
                    GoFileManager.shared.upload(urlPath: "/wangpan/api/resources/\(self.currentPath)/", filename: "\(UUID().uuidString).\(url.pathExtension)", tmpPath: url.absoluteString)
                } failure: { _ in
                    print("获取视频地址失败")
                }
                
            }
        } else {
            assets.forEach { asset in
                guard let phAsset = asset as? PHAsset else { return }
                phAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { [weak self] editingInput, info in
                    guard let self = self else { return }
                    if let input = editingInput, let path = input.fullSizeImageURL {
                        GoFileManager.shared.upload(urlPath: "/wangpan/api/resources/\(self.currentPath)/", filename: "\(UUID().uuidString).\(path.pathExtension)", tmpPath: path.absoluteString)
                    } else {
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .highQualityFormat
                        options.resizeMode = .exact
                        options.isSynchronous = true
                        
                        let imageSize = CGSize(width: phAsset.pixelWidth,
                                               height: phAsset.pixelHeight)
                        /* For faster performance, and maybe degraded image */
                        PHImageManager.default().requestImage(for: phAsset,
                                                                 targetSize: imageSize,
                                                                 contentMode: .aspectFill,
                                                                 options: options,
                                                                 resultHandler: { (image, info) -> Void in
                            if let data = image?.pngData() {
                                let url = FileManager.default.temporaryDirectory
                                let fileName = "\(UUID().uuidString).png"
                                let fileUrl = url.appendingPathComponent(fileName)
                                try? data.write(to: fileUrl)
                                GoFileManager.shared.upload(urlPath: "/wangpan/api/resources/\(self.currentPath)/", filename: fileName, tmpPath: fileUrl.absoluteString)
                            }
                        })
                    }
                    
                    
                }
            }
        }
        
        SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
        
        
    }
}

extension FolderViewController: DocumentDelegate {
    
    /// 选中的其他文件
    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            let name = pickedDoc.fileURL.lastPathComponent
            // 选择的上传文件
            GoFileManager.shared.upload(urlPath: "/wangpan/api/resources/\(currentPath)/", filename: name, tmpPath: pickedDoc.fileURL.absoluteString.removingPercentEncoding ?? pickedDoc.fileURL.absoluteString)
            SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
            
            
        }
    }
}
