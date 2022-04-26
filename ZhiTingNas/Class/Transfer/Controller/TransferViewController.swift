//
//  TransferViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/31.
//

import UIKit

class TransferViewController: BaseViewController {
    enum TransferListType {
        /// 下载列表
        case download
        /// 传输列表
        case upload
        /// 备份列表
        case backup
    }
    
    var type: TransferListType = .upload

    lazy var documentVC = UIDocumentInteractionController()
    
    var timer: Timer?
    
    var transitionUtil = FolderTransitionUtil()
    
    lazy var emptyView = TransferEmptyView()
    
    private lazy var headerView = FolderDetailHeader(currentFileName: "传输列表").then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var segmentView = UIView().then {
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    private lazy var updateBtn = Button().then {
        $0.tag = 1
        $0.layer.cornerRadius = ZTScaleValue(8)
        $0.layer.masksToBounds = true
        $0.setTitle("上传列表", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.backgroundColor = .custom(.blue_427aed)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
        $0.isSelected = true
    }
    
    private lazy var downloadBtn = Button().then {
        $0.tag = 2
        $0.layer.cornerRadius = ZTScaleValue(8)
        $0.layer.masksToBounds = true
        $0.setTitle("下载列表", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    private lazy var backupBtn = Button().then {
        $0.tag = 3
        $0.layer.cornerRadius = ZTScaleValue(8)
        $0.layer.masksToBounds = true
        $0.setTitle("备份列表", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .selected)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(TransferDownloadCell.self, forCellReuseIdentifier: TransferDownloadCell.reusableIdentifier)
        $0.register(TransferUploadCell.self, forCellReuseIdentifier: TransferUploadCell.reusableIdentifier)
        $0.register(TransferHeader.self, forHeaderFooterViewReuseIdentifier: TransferHeader.reusableIdentifier)
        $0.sectionFooterHeight = 0
    }
    
    // MARK: - 下载任务
    var downloadItems = [GoFileDownloadInfoModel]()
    
    var succeededDownloadItems: [GoFileDownloadInfoModel] {
        return downloadItems.filter({ $0.status == 3 }).sorted(by: { $0.create_time > $1.create_time })
    }
    
    var unSucceededDownloadItems: [GoFileDownloadInfoModel] {
        return downloadItems.filter({ $0.status != 3 })
    }
    
    // MARK: - 上传任务
    var uploadItems = [GoFileUploadInfoModel]()
    
    var succeededUploadItems: [GoFileUploadInfoModel] {
        return uploadItems.filter({ $0.status == 3 }).sorted(by: { $0.create_time > $1.create_time })
    }
    
    var unSucceededUploadItems: [GoFileUploadInfoModel] {
        return uploadItems.filter({ $0.status != 3 })
    }
    
    // MARK: - 备份任务
    var succeededBackupItems = [GoFileUploadInfoModel]()
    
    var unSucceededBackupItems = [GoFileUploadInfoModel]()
    
    var failedBackupItems = [GoFileUploadInfoModel]()
    
    var onGoingBackupNum = 0

    private var myFileDetailView = FileDetailAlertView(title: "文件详情".localizedString)
    

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        getListData()
    }

    private func getListData() {
        timer?.invalidate()
        
        downloadItems.removeAll()
        uploadItems.removeAll()
        succeededBackupItems.removeAll()
        unSucceededBackupItems.removeAll()
        tableView.reloadData()

        switch type {
        case .download:
            getDownloadList()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDownloadList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
            
        case .upload:
            getUploadList()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getUploadList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
            
        case .backup:
            getBackupList()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getBackupList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }

        
    }
    
    /// 获取下载列表
    @objc private func getDownloadList() {
        downloadItems = GoFileManager.shared.getDownloadList()
        
        if tableView.indexPathsForVisibleRows?.count == 0 {
            tableView.reloadData()
            return
        }

        if tableView.numberOfRows(inSection: 0) == unSucceededDownloadItems.count {
            /// 仅更新可视范围内的cell
            tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if let cell = tableView.cellForRow(at: indexPath) as? TransferDownloadCell {
                    if indexPath.section == 0 && indexPath.row < unSucceededDownloadItems.count {
                        cell.setDownloadModel(model: unSucceededDownloadItems[indexPath.row])
                        
                    }
                }
            }
        } else {
            tableView.reloadData()
        }
        
        if tableView.numberOfRows(inSection: 1) != succeededDownloadItems.count {
            tableView.reloadData()
        }
        
        if let header = tableView.headerView(forSection: 0) as? TransferHeader {
            header.label.text = "正在下载".localizedString + " (\(unSucceededDownloadItems.count))"
            header.isHidden = (unSucceededDownloadItems.count == 0)
            if unSucceededDownloadItems.filter({ $0.status == 1 }).count > 0 {
                header.button.setTitle("全部暂停".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.stopAllDownLoadTask()
                }
            } else {
                header.button.setTitle("全部下载".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.startAllDownLoadTask()
                }
            }
        }
   
    }
    
    /// 获取上传列表
    @objc private func getUploadList() {
        uploadItems = GoFileManager.shared.getUploadList()
        
        if tableView.indexPathsForVisibleRows?.count == 0 {
            tableView.reloadData()
            return
        }

        if tableView.numberOfRows(inSection: 0) == unSucceededUploadItems.count {
            /// 仅更新可视范围内的cell
            tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if let cell = tableView.cellForRow(at: indexPath) as? TransferUploadCell {
                    if indexPath.section == 0 && indexPath.row < unSucceededUploadItems.count {
                        cell.setUploadModel(model: unSucceededUploadItems[indexPath.row])
                        
                    }
                }
            }
        } else {
            tableView.reloadData()
        }
        
        

        if tableView.numberOfRows(inSection: 1) != succeededUploadItems.count {
            tableView.reloadData()
        }
        
        if let header = tableView.headerView(forSection: 0) as? TransferHeader {
            header.label.text = "正在上传".localizedString + " (\(unSucceededUploadItems.count))"
            header.isHidden = (unSucceededUploadItems.count == 0)
            if unSucceededUploadItems.filter({ $0.status == 1 }).count > 0 {
                header.button.setTitle("全部暂停".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.stopAllUploadTask(isBackup: 0)
                }
            } else {
                header.button.setTitle("全部上传".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.startAllUploadTask(isBackup: 0)
                }
            }
        }
    }
    
    /// 获取备份列表
    @objc private func getBackupList() {
        let (unSuccess, success, failed, onGoingNum) = GoFileManager.shared.getBackupList()
        succeededBackupItems = success
        unSucceededBackupItems = unSuccess
        failedBackupItems = failed
        onGoingBackupNum = onGoingNum
        
        if tableView.indexPathsForVisibleRows?.count == 0 {
            tableView.reloadData()
            return
        }

        if tableView.numberOfRows(inSection: 1) == unSucceededBackupItems.count && tableView.numberOfRows(inSection: 0) == failedBackupItems.count {
            /// 仅更新可视范围内的cell
            tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if let cell = tableView.cellForRow(at: indexPath) as? TransferUploadCell {
                    if indexPath.section == 1 && indexPath.row < unSucceededBackupItems.count {
                        cell.setUploadModel(model: unSucceededBackupItems[indexPath.row])
                        
                    }
                }
            }
        } else {
            tableView.reloadData()
        }
        
        

        if tableView.numberOfRows(inSection: 2) != succeededBackupItems.count || tableView.numberOfRows(inSection: 0) != failedBackupItems.count {
            tableView.reloadData()
        }
        
        if let header = tableView.headerView(forSection: 1) as? TransferHeader {
            header.label.text = "正在进行".localizedString + " (\(onGoingNum))"
            header.isHidden = (unSucceededBackupItems.count == 0)
            if unSucceededBackupItems.filter({ $0.status == 1 }).count > 0 {
                header.button.setTitle("全部暂停".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.stopAllUploadTask(isBackup: 1)
                }
            } else {
                header.button.setTitle("全部开始".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.startAllUploadTask(isBackup: 1)
                }
            }
        }
    }
    
    override func setupViews() {
        view.addSubview(headerView)
        headerView.setBtns(btns: [])
        headerView.actionCallback = { [weak self] tag in
            switch tag {
            case 0:
                self?.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
        view.addSubview(segmentView)
        segmentView.addSubview(updateBtn)
        segmentView.addSubview(downloadBtn)
        segmentView.addSubview(backupBtn)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height + ZTScaleValue(10))
        }
        segmentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        let btnWidth = (Screen.screenWidth - 30.ztScaleValue - 20) / 3

        updateBtn.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(btnWidth)
            $0.height.equalTo(ZTScaleValue(40))
         }
         
        downloadBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(btnWidth)
            $0.height.equalTo(ZTScaleValue(40))
         }
        
        backupBtn.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(btnWidth)
            $0.height.equalTo(ZTScaleValue(40))
         }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func showFileDetailView(downloadTask: GoFileDownloadInfoModel) {
        let file = FileModel()
        file.mod_time = downloadTask.create_time
        file.size = downloadTask.size
        file.name = downloadTask.name
        file.read = 1
        file.write = 1
        file.deleted = 1
        file.type = 1
        file.thumbnail_url = downloadTask.thumbnail_url
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = url.appendingPathComponent("/goFileItems/\(file.name)")
            switch ZTCTool.resourceTypeBy(fileName: file.name) {
            case .ppt,.pdf,.txt,.excel,.document,.music,.picture,.video:
                myFileDetailView.setCurrentFileModel(file: file, types: [.preview,.open],filePath: fileUrl.absoluteString)

            default:
                myFileDetailView.setCurrentFileModel(file: file, types: [.open],filePath: fileUrl.absoluteString)
            }
        }else{
            myFileDetailView.setCurrentFileModel(file: file, types: [.open])
        }
        myFileDetailView.selectCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .preview:
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(file.name)")

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
                        let picSet = self.downloadItems.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                        let index = picSet.firstIndex(where: {$0.name == file.name}) ?? 0
                        let picStringSet = picSet.map({url.appendingPathComponent("/goFileItems/\($0.name)").absoluteString})
                        let titleSet = picSet.map(\.name)

                        let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                        
                        break
                    case .document,.excel,.txt,.pdf,.ppt:
                        let playerVC = MultimediaController(type: .document(title: file.name, url: fileUrl))
                            playerVC.modalPresentationStyle = .fullScreen
                            playerVC.transitioningDelegate = self.transitionUtil
                            self.present(playerVC, animated: true, completion: nil)
                    default:
                        break
                    }

                }

                self.myFileDetailView.removeFromSuperview()
            case .open:
                
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(file.name)")
                    self.documentVC.url = fileUrl
                    let rect = CGRect(x: self.view.bounds.size.width, y: 40, width: 0, height: 0)
                    self.documentVC.presentOpenInMenu(from: rect, in: self.view, animated: true)
                }
                
                self.myFileDetailView.removeFromSuperview()
                
            case .delete:
                GoFileManager.shared.deleteDownloadTask(by: downloadTask)
                self.myFileDetailView.removeFromSuperview()
                self.getListData()
            default:
                break
            }
        }
        SceneDelegate.shared.window?.addSubview(myFileDetailView)
    }

}

extension TransferViewController {
    @objc func buttonOnPress(sender:Button){
        if sender.tag == 1 {
            updateBtn.isSelected = true
            updateBtn.backgroundColor = .custom(.blue_427aed)
            downloadBtn.isSelected = false
            downloadBtn.backgroundColor = .custom(.gray_f6f8fd)
            backupBtn.isSelected = false
            backupBtn.backgroundColor = .custom(.gray_f6f8fd)
            type = .upload
            //更新上传数据
            getListData()
        } else if sender.tag == 2 {
            updateBtn.isSelected = false
            updateBtn.backgroundColor = .custom(.gray_f6f8fd)
            backupBtn.isSelected = false
            backupBtn.backgroundColor = .custom(.gray_f6f8fd)
            downloadBtn.isSelected = true
            downloadBtn.backgroundColor = .custom(.blue_427aed)
            type = .download
            //更新下载数据
            getListData()
        } else {
            updateBtn.isSelected = false
            updateBtn.backgroundColor = .custom(.gray_f6f8fd)
            downloadBtn.isSelected = false
            downloadBtn.backgroundColor = .custom(.gray_f6f8fd)
            backupBtn.isSelected = true
            backupBtn.backgroundColor = .custom(.blue_427aed)
            type = .backup
            //更新备份数据
            getListData()
        }
    }
    
    func presentFolderView(path: String) {
        let vc = DownloadedFolderViewController()
        vc.currentPath = path
        vc.currentPaths = [path]
        let nav = BaseNavigationViewController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.transitioningDelegate = self.transitionUtil
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSource
extension TransferViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case .download:
            if downloadItems.count == 0 {
                view.addSubview(emptyView)
                emptyView.snp.makeConstraints {
                    $0.edges.equalTo(tableView.snp.edges)
                }
            } else {
                emptyView.removeFromSuperview()
            }
            return 2
            
        case .upload:
            if uploadItems.count == 0 {
                view.addSubview(emptyView)
                emptyView.snp.makeConstraints {
                    $0.edges.equalTo(tableView.snp.edges)
                }
            } else {
                emptyView.removeFromSuperview()
            }
            return 2
            
        case .backup:
            if unSucceededBackupItems.count == 0 && succeededBackupItems.count == 0 {
                view.addSubview(emptyView)
                emptyView.snp.makeConstraints {
                    $0.edges.equalTo(tableView.snp.edges)
                }
            } else {
                emptyView.removeFromSuperview()
            }
            return 3
            
        }
          

        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TransferHeader.reusableIdentifier) as! TransferHeader
        
        switch type {
        case .download:
            if section == 0 {
                header.label.text = "正在下载".localizedString + " (\(unSucceededDownloadItems.count))"
                header.isHidden = (unSucceededDownloadItems.count == 0)
                if unSucceededDownloadItems.filter({ $0.status == 1 }).count > 0 {
                    header.button.setTitle("全部暂停".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.stopAllDownLoadTask()
                    }
                } else {
                    header.button.setTitle("全部下载".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.startAllDownLoadTask()
                    }
                }
                
            } else {
                header.label.text = "下载完成".localizedString + " (\(succeededDownloadItems.count))"
                header.isHidden = (succeededDownloadItems.count == 0)
                header.button.setTitle("清空".localizedString, for: .normal)
                header.button.clickCallBack = { [weak self] _ in
                    guard let self = self else { return }
                    GoFileManager.shared.deleteAllDownloadRecode()
                    for item in self.succeededDownloadItems {
                        if let url = GoFileManager.shared.goCacheUrl?.appendingPathComponent(item.name) {
                            DownloadedDocumentManager.shared.deleteFile(url: url)
                        }
                    }
                }
            }
            
        case .upload:
            if section == 0 {
                header.label.text = "正在上传".localizedString + " (\(unSucceededUploadItems.count))"
                header.isHidden = (unSucceededUploadItems.count == 0)
                if unSucceededUploadItems.filter({ $0.status == 1 }).count > 0 {
                    header.button.setTitle("全部暂停".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.stopAllUploadTask(isBackup: 0)
                    }
                } else {
                    header.button.setTitle("全部上传".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.startAllUploadTask(isBackup: 0)
                    }
                }
                
            } else {
                header.label.text = "上传完成".localizedString + " (\(succeededUploadItems.count))"
                header.isHidden = (succeededUploadItems.count == 0)
                header.button.setTitle("清空".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    
                    let alert = TipsAlertView(title: "提示".localizedString, detail: "仅删除记录,不会删除已上传到云盘的文件", warning: "", sureBtnTitle: "确认".localizedString)
                    alert.sureCallback = {
                        GoFileManager.shared.deleteAllUploadRecord(isBackup: 0)
                        alert.removeFromSuperview()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                    
                }
            }
            
        case .backup:
            if section == 0 {
                header.label.text = "备份失败".localizedString + " (\(failedBackupItems.count))"
                header.isHidden = (failedBackupItems.count == 0)
                header.button.setTitle("全部重试".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    GoFileManager.shared.retryAllBackups()
                }
            } else if section == 1 {
                header.label.text = "正在进行(\(onGoingBackupNum))".localizedString
                header.isHidden = (unSucceededBackupItems.count == 0)
                if unSucceededBackupItems.filter({ $0.status == 1 }).count > 0 {
                    header.button.setTitle("全部暂停".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.stopAllUploadTask(isBackup: 1)
                    }
                } else {
                    header.button.setTitle("全部开始".localizedString, for: .normal)
                    header.button.clickCallBack = { _ in
                        GoFileManager.shared.startAllUploadTask(isBackup: 1)
                    }
                }
                
            } else {
                header.label.text = "备份记录".localizedString + " (\(succeededBackupItems.count))"
                header.isHidden = (succeededBackupItems.count == 0)
                header.button.setTitle("清空".localizedString, for: .normal)
                header.button.clickCallBack = { _ in
                    let alert = TipsAlertView(title: "提示".localizedString, detail: "仅删除记录,不会删除已备份到云盘的文件", warning: "", sureBtnTitle: "确认".localizedString)
                    alert.sureCallback = {
                        GoFileManager.shared.deleteAllUploadRecord(isBackup: 1)
                        alert.removeFromSuperview()
                    }
                    SceneDelegate.shared.window?.addSubview(alert)
                }
            }

        }

        
        
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch type {
        case .download:
            if section == 0 {
                return (unSucceededDownloadItems.count == 0) ? 0 : UITableView.automaticDimension
            } else {
                return (succeededDownloadItems.count == 0) ? 0 : UITableView.automaticDimension
            }

        case .upload:
            if section == 0 {
                return (unSucceededUploadItems.count == 0) ? 0 : UITableView.automaticDimension
            } else {
                return (succeededUploadItems.count == 0) ? 0 : UITableView.automaticDimension
            }

        case .backup:
            if section == 0 {
                return (failedBackupItems.count == 0) ? 0 : UITableView.automaticDimension
            } else if section == 1 {
                return (unSucceededBackupItems.count == 0) ? 0 : UITableView.automaticDimension
            } else {
                return (succeededBackupItems.count == 0) ? 0 : UITableView.automaticDimension
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .download:
            if section == 0 {
                return unSucceededDownloadItems.count
            } else {
                return succeededDownloadItems.count
            }
            
        case .upload:
            if section == 0 {
                return unSucceededUploadItems.count
            } else {
                return succeededUploadItems.count
            }
            
        case .backup:
            if section == 0 {
                return failedBackupItems.count
            } else if section == 1 {
                return unSucceededBackupItems.count
            } else {
                return succeededBackupItems.count
            }
        }


    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .download:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferDownloadCell.reusableIdentifier, for: indexPath) as! TransferDownloadCell
                //未成功下载任务列表
                let model  = unSucceededDownloadItems[indexPath.row]
                cell.setDownloadModel(model: model)
                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.unSucceededDownloadItems[indexPath.row]
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 1:
                        GoFileManager.shared.pauseDownloadTask(by: model, type: model.type)
                    case 2:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    default:
                        break
                    }
                }
                
                cell.dirFailInfoCallback = {
                    let alert = TransferDownloadFailAlert(task: model)
                    SceneDelegate.shared.window?.addSubview(alert)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferDownloadCell.reusableIdentifier, for: indexPath) as! TransferDownloadCell
                //成功下载任务列表
                let model  = succeededDownloadItems[indexPath.row]
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(model.name)")
                    cell.setDownloadModel(model: model,filePath: fileUrl.absoluteString)
                }else{
                    cell.setDownloadModel(model: model)
                }

                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.succeededDownloadItems[indexPath.row]
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 1:
                        GoFileManager.shared.pauseDownloadTask(by: model, type: model.type)
                    case 2:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeDownloadTask(by: model, type: model.type)
                    default:
                        break
                    }
                }
                
                return cell
            }

        case .upload:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferUploadCell.reusableIdentifier, for: indexPath) as! TransferUploadCell
                // 未完成上传列表
                let model  = unSucceededUploadItems[indexPath.row]
                cell.setUploadModel(model: model)
                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.unSucceededUploadItems[indexPath.row]
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferUploadCell.reusableIdentifier, for: indexPath) as! TransferUploadCell
                //成功上传任务列表
                let model  = succeededUploadItems[indexPath.row]
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(model.name)")
                    cell.setUploadModel(model: model, filePath: fileUrl.absoluteString)
                }else{
                    cell.setUploadModel(model: model)
                }

                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.succeededUploadItems[indexPath.row]
                    
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            }
            
        case .backup:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferUploadCell.reusableIdentifier, for: indexPath) as! TransferUploadCell
                // 备份失败列表
                let model  = failedBackupItems[indexPath.row]
                cell.setUploadModel(model: model)
                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.failedBackupItems[indexPath.row]
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
                
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferUploadCell.reusableIdentifier, for: indexPath) as! TransferUploadCell
                // 正在进行备份列表
                let model  = unSucceededBackupItems[indexPath.row]
                cell.setUploadModel(model: model)
                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.unSucceededBackupItems[indexPath.row]
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TransferUploadCell.reusableIdentifier, for: indexPath) as! TransferUploadCell
                //成功备份任务列表
                let model  = succeededBackupItems[indexPath.row]
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(model.name)")
                    cell.setUploadModel(model: model, filePath: fileUrl.absoluteString)
                }else{
                    cell.setUploadModel(model: model)
                }

                cell.stateBtnCallback = { [weak self] in
                    guard let self = self else { return }
                    let model  = self.succeededBackupItems[indexPath.row]
                    
                    switch model.status {
                    case 0:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            }
            
        }

        
        
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .download:
            if indexPath.section == 1 {
                let task = succeededDownloadItems[indexPath.row]
                if task.type == "file" {
                    showFileDetailView(downloadTask: task)
                } else {
                    presentFolderView(path: task.name)
                }
            }
        case .upload:
            if indexPath.section == 1 {
                let task = succeededUploadItems[indexPath.row]
                let urlString = "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(task.preview_url)"
                guard let queryStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let fileUrl = URL(string: queryStr)
                else {
                    return
                }
                //判断类型
                switch ZTCTool.resourceTypeBy(fileName: task.name) {
                case .video:
                    let playerVC = MultimediaController(type: .video(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                
                case .music:
                    let playerVC = MultimediaController(type: .music(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                    
                case .picture:
                    //获取图片集，以及当前第几个
                    let picSet = self.succeededUploadItems.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                    let index = picSet.firstIndex(where: {$0.name == task.name}) ?? 0
                    let picStringSet = picSet.map({ fileModel -> String in
                        guard let url = URL(string: "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(fileModel.preview_url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileModel.preview_url)") else { return "" }
                        
                        return url.absoluteString
                    })
                    let titleSet = picSet.map(\.name)

                    let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                    
                case .document,.excel,.txt,.pdf,.ppt:
                    let playerVC = MultimediaController(type: .document(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                default:
                    break
                }
            }
        case .backup:
            if indexPath.section == 2 {
                let task = succeededBackupItems[indexPath.row]
                let urlString = "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(task.preview_url)"
                guard let queryStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let fileUrl = URL(string: queryStr)
                else {
                    return
                }
                //判断类型
                switch ZTCTool.resourceTypeBy(fileName: task.name) {
                case .video:
                    let playerVC = MultimediaController(type: .video(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                
                case .music:
                    let playerVC = MultimediaController(type: .music(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                    
                case .picture:
                    //获取图片集，以及当前第几个
                    let picSet = self.succeededBackupItems.filter({ZTCTool.resourceTypeBy(fileName: $0.name) == .picture})
                    let index = picSet.firstIndex(where: {$0.name == task.name}) ?? 0
                    let picStringSet = picSet.map({ fileModel -> String in
                        guard let url = URL(string: "\(AreaManager.shared.currentArea.requestURL)/wangpan/api/download\(fileModel.preview_url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileModel.preview_url)") else { return "" }
                        
                        return url.absoluteString
                    })
                    let titleSet = picSet.map(\.name)

                    let playerVC = MultimediaController(type: .picture(titleSet: titleSet, picSet: picStringSet, index: index, isFromLocation: true))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                    
                case .document,.excel,.txt,.pdf,.ppt:
                    let playerVC = MultimediaController(type: .document(title: task.name, url: fileUrl))
                        playerVC.modalPresentationStyle = .fullScreen
                        playerVC.transitioningDelegate = self.transitionUtil
                        self.present(playerVC, animated: true, completion: nil)
                default:
                    break
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let handler: UIContextualAction.Handler = { [weak self] action, sourceView, complete in
            guard let self = self else { return }
            self.timer?.invalidate()
            switch self.type {
            case .download: // 下载
                let model: GoFileDownloadInfoModel
                if indexPath.section == 0 {
                    model = self.unSucceededDownloadItems[indexPath.row]
                } else {
                    model = self.succeededDownloadItems[indexPath.row]
                }
                GoFileManager.shared.deleteDownloadTask(by: model)
                
                
            case .upload: // 上传
                let model: GoFileUploadInfoModel
                if indexPath.section == 0 {
                    model = self.unSucceededUploadItems[indexPath.row]
                } else {
                    model = self.succeededUploadItems[indexPath.row]
                }
                GoFileManager.shared.deleteUploadTask(by: model)
                
                
            case .backup: // 备份
                let model: GoFileUploadInfoModel
                if indexPath.section == 0 {
                    model = self.failedBackupItems[indexPath.row]
                } else if indexPath.section == 1 {
                    model = self.unSucceededBackupItems[indexPath.row]
                } else {
                    model = self.succeededBackupItems[indexPath.row]
                }
                GoFileManager.shared.deleteUploadTask(by: model)
                

            }
            
            self.getListData()
            
        }
        
        let action = UIContextualAction(style: .destructive, title: "删除".localizedString, handler: handler)
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

}



class TransferEmptyView: UIView {
    private lazy var icon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.empty_file)
    }
    
    private lazy var label = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "暂无数据"
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
