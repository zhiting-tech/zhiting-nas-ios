//
//  TransferViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/31.
//

import UIKit

class TransferViewController: BaseViewController {
    enum TransferListType {
        case download
        case upload
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
        $0.setTitleColor(.custom(.black_3f4663), for: .selected)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.backgroundColor = .custom(.white_ffffff)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
        $0.isSelected = true
    }
    
    private lazy var downloadBtn = Button().then {
        $0.tag = 2
        $0.layer.cornerRadius = ZTScaleValue(8)
        $0.layer.masksToBounds = true
        $0.setTitle("下载列表", for: .normal)
        $0.setTitleColor(.custom(.gray_a2a7ae), for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .selected)
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
        //创建Cell
        $0.register(TransferDownloadCell.self, forCellReuseIdentifier: TransferDownloadCell.reusableIdentifier)
        $0.register(TransferUploadCell.self, forCellReuseIdentifier: TransferUploadCell.reusableIdentifier)
        $0.register(TransferHeader.self, forHeaderFooterViewReuseIdentifier: TransferHeader.reusableIdentifier)
        $0.sectionFooterHeight = 0
    }
    
    /// 下载任务
    var downloadItems = [GoFileDownloadInfoModel]()
    
    var succeededDownloadItems: [GoFileDownloadInfoModel] {
        return downloadItems.filter({ $0.status == 3 }).sorted(by: { $0.create_time > $1.create_time })
    }
    
    var unSucceededDownloadItems: [GoFileDownloadInfoModel] {
        return downloadItems.filter({ $0.status != 3 })
    }
    
    /// 上传任务
    var uploadItems = [GoFileUploadInfoModel]()
    
    var succeededUploadItems: [GoFileUploadInfoModel] {
        return uploadItems.filter({ $0.status == 3 }).sorted(by: { $0.create_time > $1.create_time })
    }
    
    var unSucceededUploadItems: [GoFileUploadInfoModel] {
        return uploadItems.filter({ $0.status != 3 })
    }
    

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
        if type == .download {
            getDownloadList()
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDownloadList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        } else {
            getUploadList()
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getUploadList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    @objc
    private func getDownloadList() {
        downloadItems = GoFileNewManager.shared.getDownloadList()
        tableView.reloadData()
        if downloadItems.filter({ $0.status != 3 }).count == 0 {
            timer?.invalidate()
            
        }
        
    }
    
    @objc
    private func getUploadList() {
        uploadItems = GoFileNewManager.shared.getUploadList()
        tableView.reloadData()
        if uploadItems.filter({ $0.status != 3 }).count == 0 {
            timer?.invalidate()
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
        updateBtn.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX).multipliedBy(0.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(145))
            $0.height.equalTo(ZTScaleValue(40))
         }
         
        downloadBtn.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX).multipliedBy(1.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(145))
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
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = url.appendingPathComponent("/goFileItems/\(file.name)")
            myFileDetailView.setCurrentFileModel(file: file, types: [.open],filePath: fileUrl.absoluteString)
        }else{
            myFileDetailView.setCurrentFileModel(file: file, types: [.open])
        }
        myFileDetailView.selectCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .open:
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(file.name)")
                    self.documentVC.url = fileUrl
                    let rect = CGRect(x: self.view.bounds.size.width, y: 40, width: 0, height: 0)
                    self.documentVC.presentOpenInMenu(from: rect, in: self.view, animated: true)

                }

                self.myFileDetailView.removeFromSuperview()
            case .delete:
                GoFileNewManager.shared.deleteDownloadTask(by: downloadTask)
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
            updateBtn.backgroundColor = .custom(.white_ffffff)
            downloadBtn.isSelected = false
            downloadBtn.backgroundColor = .custom(.gray_f6f8fd)
            type = .upload
            //更新上传数据
            getListData()
        } else {
            updateBtn.isSelected = false
            updateBtn.backgroundColor = .custom(.gray_f6f8fd)
            downloadBtn.isSelected = true
            downloadBtn.backgroundColor = .custom(.white_ffffff)
            type = .download
            //更新下载数据
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
        /// 空列表视图
        if type == .download && downloadItems.count == 0 {
            view.addSubview(emptyView)
            emptyView.snp.makeConstraints {
                $0.edges.equalTo(tableView.snp.edges)
            }
        } else if type == .upload && uploadItems.count == 0 {
            view.addSubview(emptyView)
            emptyView.snp.makeConstraints {
                $0.edges.equalTo(tableView.snp.edges)
            }
        } else {
            emptyView.removeFromSuperview()
        }

        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TransferHeader.reusableIdentifier) as! TransferHeader
        if section == 0 {
            if type == .download {
                header.label.text = "正在下载".localizedString + " (\(unSucceededDownloadItems.count))"
                header.isHidden = (unSucceededDownloadItems.count == 0)
            } else {
                header.label.text = "正在上传".localizedString + " (\(unSucceededUploadItems.count))"
                header.isHidden = (unSucceededUploadItems.count == 0)
            }
            
        } else {
            if type == .download {
                header.label.text = "下载完成".localizedString + " (\(succeededDownloadItems.count))"
                header.isHidden = (succeededDownloadItems.count == 0)
            } else {
                header.label.text = "上传完成".localizedString + " (\(succeededUploadItems.count))"
                header.isHidden = (succeededUploadItems.count == 0)
            }
            
        }
        
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if type == .download {
                return (unSucceededDownloadItems.count == 0) ? 0 : UITableView.automaticDimension
            } else {
                return (unSucceededUploadItems.count == 0) ? 0 : UITableView.automaticDimension
            }
           
        } else {
            if type == .download {
                return (succeededDownloadItems.count == 0) ? 0 : UITableView.automaticDimension
            } else {
                return (succeededUploadItems.count == 0) ? 0 : UITableView.automaticDimension
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { /// 正在下载 || 下载完成
            if type == .download {
                return unSucceededDownloadItems.count
            } else {
                return unSucceededUploadItems.count
            }
            
        } else { /// 下载完成 || 上传完成
            if type == .download {
                return succeededDownloadItems.count
            } else {
                return succeededUploadItems.count
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if type == .download {
                let cell = TransferDownloadCell()
                //未成功下载任务列表
                let model  = unSucceededDownloadItems[indexPath.row]
                cell.setDownloadModel(model: model)
                cell.stateBtnCallback = {
                    switch model.status {
                    case 0:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 1:
                        GoFileNewManager.shared.pauseDownloadTask(by: model, type: model.type)
                    case 2:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 3:
                        break
                    case 4:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
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
                let cell = TransferUploadCell()
                // 未完成上传列表
                let model  = unSucceededUploadItems[indexPath.row]
                cell.setUploadModel(model: model)
                cell.stateBtnCallback = {
                    switch model.status {
                    case 0:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileNewManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            }
            
        } else {
            if type == .download {
                let cell = TransferDownloadCell()
                //成功下载任务列表
                let model  = succeededDownloadItems[indexPath.row]
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(model.name)")
                    cell.setDownloadModel(model: model,filePath: fileUrl.absoluteString)
                }else{
                    cell.setDownloadModel(model: model)
                }

                cell.stateBtnCallback = {
                    switch model.status {
                    case 0:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 1:
                        GoFileNewManager.shared.pauseDownloadTask(by: model, type: model.type)
                    case 2:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
                    case 3:
                        break
                    case 4:
                        GoFileNewManager.shared.resumeDownloadTask(by: model, type: model.type)
                    default:
                        break
                    }
                }
                
                return cell
            } else {
                let cell = TransferUploadCell()
                //成功上传任务列表
                let model  = succeededUploadItems[indexPath.row]
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileUrl = url.appendingPathComponent("/goFileItems/\(model.name)")
                    cell.setUploadModel(model: model, filePath: fileUrl.absoluteString)
                }else{
                    cell.setUploadModel(model: model)
                }

                cell.stateBtnCallback = {
                    switch model.status {
                    case 0:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    case 1:
                        GoFileNewManager.shared.pauseUploadTask(by: model)
                    case 2:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    case 3:
                        break
                    case 4:
                        GoFileNewManager.shared.resumeUploadTask(by: model)
                    default:
                        break
                    }
                }
                
                return cell
            }
            
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        } else {
            if type == .download {
                let task = succeededDownloadItems[indexPath.row]
                if task.type == "file" {
                    showFileDetailView(downloadTask: task)
                } else {
                    presentFolderView(path: task.name)
                }
                
            }
            
        }
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
