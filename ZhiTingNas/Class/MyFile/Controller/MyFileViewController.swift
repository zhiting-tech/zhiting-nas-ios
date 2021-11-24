//
//  MyFileViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit
import TZImagePickerController

class MyFileViewController: BaseViewController {
    private var currentDatas = [FileModel]()
    private var seletedFiles = [FileModel]()//选中的文件
    private var funtionTabbarIsShow = false
    
    
    private var isGetAllData = false//是否已获取服务器所有数据
    private lazy var emptyView = FileEmptyView()
    
    //加密文件夹弹框
    private var tipsTestFieldAlert: TipsTestFieldAlertView?

    var transitionUtil = FolderTransitionUtil()

    private lazy var myFileHeader = CustomHeaderView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    

    private lazy var filePathLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.text = "文件"
        $0.textColor = .custom(.gray_a2a7ae)
    }
    
    private var myFileDetailView = FileDetailAlertView(title: "文件详情")
    private var setNameView: SetNameAlertView?


    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(FileTableViewCell.self, forCellReuseIdentifier: FileTableViewCell.reusableIdentifier)

    }

    private lazy var areaSelectView = SwtichAreaView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = GIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reload))
        tableView.mj_footer = MJRefreshBackNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadNextData))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        LoadingView.show()
        reload()
        let transferingItemsCount = GoFileNewManager.shared.getTotalonGoingCount()//GoFileNewManager.shared.getDownloadList().filter({ $0.status != 3 }).count + GoFileNewManager.shared.getUploadList().filter({ $0.status != 3 }).count
        self.myFileHeader.transferListBtn.setUpNumber(value: transferingItemsCount)
    }
    
    override func setupViews() {
        view.addSubview(myFileHeader)
        myFileHeader.setBtns(btns: [.transfer])
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
        

        myFileHeader.transferListBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            print("点击传输列表")
            let transferVC = TransferViewController()
            self.navigationController?.pushViewController(transferVC, animated: true)
            
        }
        //fileDetailAction
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
                self.reload()
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
      
    @objc private func reload(){
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
            currentDatas.removeAll()
            isGetAllData = false
            tableView.mj_footer?.resetNoMoreData()
        }
        
        let page = (currentDatas.count / 30) + 1

        NetworkManager.shared.fileList(path: "/", page: page, page_size: 30) { [weak self] response in
            guard let self = self else { return }
            LoadingView.hide()
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            
            //删选没有可读权限的文件
            let datas = response.list.filter({$0.read != 0})
            
            if isReload {//下拉刷新 or 首次加载数据
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
                    }else{
                        self.emptyView.removeFromSuperview()
                        self.currentDatas = datas
                        if response.list.count < 30 {
                            self.tableView.mj_footer?.isHidden = true
                        }else{
                            self.tableView.mj_footer?.isHidden = false
                        }
                        self.tableView.reloadData()
                    }
            }else{//上拉加载更多数据
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
            LoadingView.hide()
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
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
            self.showToast("\(err)")
        }
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MyFileViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.reusableIdentifier, for: indexPath) as! FileTableViewCell
        cell.selectionStyle = .none
        cell.setModel(currentModel: currentDatas[indexPath.row])
        cell.selectBtn.isHidden = true
        return cell
    }
    
    private func pushToFolder(isNeedPwd:Bool,file:FileModel){
        let vc = FolderViewController()
        vc.currentPath = file.path
        vc.currentPaths = ["文件",file.name]
        vc.encrytRootFile = file
        vc.isWriteRoot = (file.write == 1)
        
        let key = AreaManager.shared.currentArea.scope_token + file.path
        if file.is_encrypt == 1 {
            vc.rootPasswordKey = key
        }else{
            vc.rootPasswordKey = ""
        }

        if isNeedPwd {
            //存储文件夹根目录Key
            self.tipsTestFieldAlert = TipsTestFieldAlertView.show(message: "请输入密码", sureCallback: { pwd in
                print("密码是\(pwd)")
                NetworkManager.shared.decryptFolder(name: file.path, password: pwd) {[weak self] response in
                    guard let self = self else {return}
                    //存储时间和密码
                    let pwdModel = PasswordModel()
                    pwdModel.password = pwd
                    //当前时间
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    pwdModel.saveTime = dateFormatter.string(from: Date())
                    UserDefaults.standard.setValue(pwdModel.toJSONString(prettyPrint:true), forKey: key)
                    
                    //解密成功，进入文件夹
                    let nav = BaseNavigationViewController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    nav.transitioningDelegate = self.transitionUtil
                    self.navigationController?.present(nav, animated: true, completion: nil)
                } failureCallback: { code, err in
                    self.showToast(err)
                }
            })
        }else{
            //无需输入密码
            let nav = BaseNavigationViewController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.transitioningDelegate = transitionUtil
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击cell
        
        print("点击cell")
        let file = currentDatas[indexPath.row]
        if file.type == 0 {//文件夹
            self.hideAllFuntionView()
                if file.is_encrypt == 1 {//加密文件
                
                //存储的密码对象
                let key = AreaManager.shared.currentArea.scope_token + file.path
                    let pwdJsonStr:String = UserDefaults.standard.value(forKey: key) as? String ?? ""
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
                //无需输入密码
                pushToFolder(isNeedPwd: false, file: file)
            }
            return
        }
        myFileDetailView.setCurrentFileModel(file: file, types: [.download, .move, .copy, .rename, .delete])
        myFileDetailView.selectCallback = {[weak self] type in
            guard let self = self else {
                return
            }
            
            switch type {
            case .open:
                print("点击其他应用打开")
                self.myFileDetailView.removeFromSuperview()
            case .download:
                print("点击下载")
                GoFileNewManager.shared.download(path: file.path)
                
                SceneDelegate.shared.window?.makeToast("已添加至传输列表".localizedString)
                self.myFileDetailView.removeFromSuperview()
                self.tableView.reloadData()
            case .move:
                print("点击移动到")
                self.myFileDetailView.removeFromSuperview()
                self.pushToMoveFolder(type: .move, fileModel: file)
            case .copy:
                print("点击复制到")
                self.myFileDetailView.removeFromSuperview()
                self.pushToMoveFolder(type: .copy, fileModel: file)
            case .rename:
                print("点击重命名")
                self.myFileDetailView.removeFromSuperview()
                self.showResetNameView(name: file.name, isFile: file.type == 1)
                self.setNameView?.setNameCallback = { [weak self] name in
                    guard let self = self else { return }
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
                        LoadingView.hide()
                        SceneDelegate.shared.window?.makeToast("重命名成功".localizedString)
                    } failureCallback: { code, err in
                        SceneDelegate.shared.window?.makeToast(err)
                        LoadingView.hide()
                    }
                }
            case .delete:
                print("点击删除")
                LoadingView.show()
                NetworkManager.shared.deleteFile(paths: [file.path]) { [weak self] response in
                    guard let self = self else { return }
                    self.myFileDetailView.removeFromSuperview()
                    self.tableView.beginUpdates()
                    self.currentDatas.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                    LoadingView.hide()
                    SceneDelegate.shared.window?.makeToast("删除成功".localizedString)
                } failureCallback: {  code, err in
                    SceneDelegate.shared.window?.makeToast(err)
                    LoadingView.hide()
                }

            }
        }
        
        showFileDetailView()
    }
}

extension MyFileViewController {
    private func showFileDetailView(){
        SceneDelegate.shared.window?.addSubview(myFileDetailView)
    }
    

    
    private func showResetNameView(name:String, isFile: Bool){
        setNameView = SetNameAlertView(setNameType: .resetName(isFile: isFile), currentName: name)
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }
    
    
    private func hideAllFuntionView(){
        myFileDetailView.removeFromSuperview()
        setNameView?.removeFromSuperview()
        tableView.reloadData()
    }
    
    private func pushToMoveFolder(type:MoveType,fileModel: FileModel?){
            let vc = ChangeFolderPlaceController()
            vc.type = type
            vc.isRootPath = true
            vc.currentPaths = ["根目录"]
            if fileModel != nil {
                vc.seletedFiles = [fileModel ?? FileModel()]
            }else{
                vc.seletedFiles = self.seletedFiles
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            self.hideAllFuntionView()

        }

}



class PasswordModel: BaseModel {
        var password: String = ""
        var saveTime: String = ""
}

class FileEmptyView: UIView {
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
