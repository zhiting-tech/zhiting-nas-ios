//
//  ShareFileViewController.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/14.
//

import UIKit

class ShareFileViewController: BaseViewController {

    private var currentDatas = [FileModel]()
    private var seletedFiles = [FileModel]()//选中的文件
    private var funtionTabbarIsShow = false
    private lazy var emptyView = FileEmptyView()


    private lazy var myFileHeader = CustomHeaderView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var funtionTabbarView = FunctionTabbarView().then {
        $0.backgroundColor = .custom(.blue_427aed)
    }
    
    private lazy var filePathLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.text = "共享文件"
        $0.textColor = .custom(.gray_a2a7ae)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(FileTableViewCell.self, forCellReuseIdentifier: FileTableViewCell.reusableIdentifier)

    }
    
    private var myFileDetailView = FileDetailAlertView(title: "文件详情")
    private var  updateFileView = UpdateFileAlertView(title: "上传文件")

    private var setNameView: SetNameAlertView?
    
    private lazy var areaSelectView = SwtichAreaView()

    var transitionUtil = FolderTransitionUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = GIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        tableView.mj_footer = MJRefreshBackNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(getDiskData))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        LoadingView.show()
        refresh()
        let transferingItemsCount = GoFileNewManager.shared.getDownloadList().filter({ $0.status != 3 }).count + GoFileNewManager.shared.getUploadList().filter({ $0.status != 3 }).count
        self.myFileHeader.transferListBtn.setUpNumber(value: transferingItemsCount)
    }
    
    override func setupViews() {
        view.addSubview(myFileHeader)
        myFileHeader.setBtns(btns: [.transfer])
        myFileHeader.transferListBtn.setUpNumber(value: 32)
        view.addSubview(filePathLabel)
        view.addSubview(tableView)
        // MARK: - selectAreaAction
        areaSelectView.areas = AreaManager.shared.getAreaList()
        if AreaManager.shared.currentArea.name != "" {
            myFileHeader.titleLabel.text = AreaManager.shared.currentArea.name
        }
        areaSelectView.selectCallback = { area in
            AreaManager.shared.currentArea = area
        }
        // MARK: - myFileHeaderAction

        myFileHeader.switchAreaCallButtonCallback = { [weak self] in
            guard let self = self else { return }
            print("切换家庭")
            SceneDelegate.shared.window?.addSubview(self.areaSelectView)
        }
        
        myFileHeader.transferListBtn.clickCallBack = { _ in
            print("点击传输列表")
            let transferVC = TransferViewController()
            self.navigationController?.pushViewController(transferVC, animated: true)
        }
        
        // MARK: - funtionTabbarAction
        funtionTabbarView.shareBtn.clickCallBack = { _ in
            print("点击分享到")
            let shareVC = FileShareController()
            shareVC.fileDatas = self.seletedFiles
            self.navigationController?.pushViewController(shareVC, animated: true)
            self.hideFunctionTabbarView()
        }
        funtionTabbarView.downloadBtn.clickCallBack = { _ in
            print("点击下载")
        }
        funtionTabbarView.copyBtn.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            print("点击复制到")
            let vc = ChangeFolderPlaceController()
            vc.isRootPath = true
            vc.currentPaths = ["根目录"]
            vc.seletedFiles = self.seletedFiles
            vc.type = .copy
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            self.hideAllFuntionView()
        }

        funtionTabbarView.resetNameBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击重命名")
            guard let file = self.seletedFiles.first else { return }
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
                                self.setNameView?.removeFromSuperview()
                                self.hideAllFuntionView()
                                self.tableView.reloadData()
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
                    self.setNameView?.removeFromSuperview()
                    self.hideAllFuntionView()
                    self.tableView.reloadData()
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
            let tipsAlert = TipsAlertView(title: "", detail: String(format: "共%d个文件/文件夹，确定删除吗？", paths.count), warning: "文件删除后不可恢复", sureBtnTitle: "确定")
            tipsAlert.sureCallback = { [weak self] in
                guard let self = self else { return }
                tipsAlert.sureBtn.buttonState = .waiting
                NetworkManager.shared.deleteFile(paths: paths) { [weak self] response in
                    guard let self = self else { return }
                    self.myFileDetailView.removeFromSuperview()
                    tipsAlert.removeFromSuperview()
                    self.hideFunctionTabbarView()
                    SceneDelegate.shared.window?.makeToast("删除成功".localizedString)
                    self.seletedFiles.removeAll()
                    self.currentDatas.removeAll()
                    self.refresh()
                } failureCallback: { code, err in
                    tipsAlert.sureBtn.buttonState = .normal
                    SceneDelegate.shared.window?.makeToast(err)
                }
            }
            SceneDelegate.shared.window?.addSubview(tipsAlert)
        }
    }
    
    override func setupConstraints() {
        myFileHeader.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        
        filePathLabel.snp.makeConstraints {
            $0.top.equalTo(myFileHeader.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalToSuperview().offset(ZTScaleValue(15.5))
            $0.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(filePathLabel.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setupSubscriptions() {
        AreaManager.shared.currentAreaPublisher
            .sink { [weak self] area in
                guard let self = self else { return }
                self.areaSelectView.tableView.reloadData()
                self.myFileHeader.titleLabel.text = area.name
                self.refresh()
            }
            .store(in: &cancellables)
        
        GoFileNewManager.shared.taskCountChangePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                let transferingItemsCount = GoFileNewManager.shared.getTotalonGoingCount()
                DispatchQueue.main.async {
                    self.myFileHeader.transferListBtn.setUpNumber(value: transferingItemsCount)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func refresh() {
        currentDatas.removeAll()
        seletedFiles.removeAll()
        tableView.reloadData()
        hideAllFuntionView()
        getDiskData()
    }
    
    @objc private func getDiskData(){
        let page = (currentDatas.count / 30) + 1
        
        NetworkManager.shared.shareFileList(page: page, page_size: 30) { [weak self] response in
            guard let self = self else {return}
            print("请求成功")
            LoadingView.hide()
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            //删选没有可读权限的文件
            let datas = response.list.filter({$0.read != 0})
            self.currentDatas.append(contentsOf: datas)
            
            
            if !response.pager.has_more {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }

            if self.currentDatas.count == 0 {
                //空数据展示页面
                self.tableView.addSubview(self.emptyView)
                self.emptyView.snp.makeConstraints {
                    $0.center.equalToSuperview()
                    $0.width.equalTo(Screen.screenWidth)
                    $0.height.equalTo(ZTScaleValue(110))
                }
                self.tableView.reloadData()
            }else{
                
                self.emptyView.removeFromSuperview()
                self.tableView.reloadData()
            }

        } failureCallback: {[weak self] code, err in
            guard let self = self else { return }
            print("请求失败")
            LoadingView.hide()
            self.tableView.mj_header?.endRefreshing()

            if self.currentDatas.count == 0 {
                //空数据展示页面
                self.tableView.addSubview(self.emptyView)
                    self.emptyView.snp.makeConstraints {
                        $0.center.equalToSuperview()
                        $0.width.equalTo(Screen.screenWidth)
                        $0.height.equalTo(ZTScaleValue(110))
                    }
                }else{
                    self.emptyView.removeFromSuperview()
                }
            self.showToast("\(err)")
        }

    }


}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ShareFileViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.reusableIdentifier, for: indexPath) as! FileTableViewCell
        cell.selectionStyle = .none
        let file = currentDatas[indexPath.row]
        if file.name == "" {
            file.name = AreaManager.shared.currentArea.name
        }
        cell.setShareModel(currentModel: currentDatas[indexPath.row])
        //除家庭文件外，共享文件可选择
        if file.is_family_path == 1 {//家庭文件
            cell.selectBtn.isHidden = true
        }else{
            if file.from_user == "" {//文件夹管理创建
                cell.selectBtn.isHidden = true
            }else{
                cell.selectBtn.isHidden = false
            }
        }
        
        cell.selectBtn.tag = indexPath.row
        
        cell.selectBtn.clickCallBack = {[weak self] sender in
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
            print(self.seletedFiles)
            if self.seletedFiles.count > 0 {
                if !self.funtionTabbarIsShow {
                    self.showFunctionTabbarView()
                }
                
                //共享文件不能移动
                self.funtionTabbarView.setMoveBtnIsEnabled(isEnabled: false)

                //权限判断
                if self.seletedFiles.filter({$0.write == 0}).count > 0 {//没有写入权限
                    self.funtionTabbarView.setShareBtnIsEnabled(isEnabled: false)
//                    self.funtionTabbarView.setCopyBtnIsEnabled(isEnabled: false)
                    self.funtionTabbarView.setResetNameBtnIsEnabled(isEnabled: false)
                    self.funtionTabbarView.setDownloadBtnIsEnabled(isEnabled: false)
                }else{
                    self.funtionTabbarView.setShareBtnIsEnabled(isEnabled: true)
//                    self.funtionTabbarView.setCopyBtnIsEnabled(isEnabled: true)
                    self.funtionTabbarView.setResetNameBtnIsEnabled(isEnabled: self.seletedFiles.count == 1)
                    self.funtionTabbarView.setDownloadBtnIsEnabled(isEnabled: true)
                }

                if self.seletedFiles.filter({$0.deleted == 0}).count > 0 {//没有删权限
                    self.funtionTabbarView.setDeleteBtnIsEnabled(isEnabled: false)
                }else{
                    self.funtionTabbarView.setDeleteBtnIsEnabled(isEnabled: true)
                }

//                }

            }else{
                self.hideFunctionTabbarView()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("点击cell")
        let file = currentDatas[indexPath.row]
        self.hideAllFuntionView()
        let vc = FolderViewController()
        vc.currentPath = file.path
        vc.currentPaths = ["共享文件",file.name]
        vc.isFromShareFile = true
        vc.shareBaseFile = file
        vc.isWriteRoot = (file.write == 1)
        let nav = BaseNavigationViewController(rootViewController: vc)
        nav.transitioningDelegate = transitionUtil
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
}

extension ShareFileViewController {
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
            $0.top.equalTo(filePathLabel.snp.bottom)
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
            $0.top.equalTo(filePathLabel.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func showFileDetailView() {
        SceneDelegate.shared.window?.addSubview(myFileDetailView)
    }
    
    private func showUpdateFileView() {
        view.addSubview(updateFileView)
        updateFileView.snp.makeConstraints {
            $0.top.equalTo(myFileHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        view.bringSubviewToFront(updateFileView)
    }
    
    private func showResetNameView(name:String, isFile: Bool) {
        setNameView = SetNameAlertView(setNameType: .resetName(isFile: isFile), currentName: name)
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }
    
    private func showCreatNewFolderView() {
        setNameView = SetNameAlertView(setNameType: .creatFile, currentName: "")
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }
    
    private func hideAllFuntionView() {
        hideFunctionTabbarView()
        myFileDetailView.removeFromSuperview()
        updateFileView.removeFromSuperview()
        setNameView?.removeFromSuperview()
    }

}

