//
//  ChangeFolderPlaceController.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/27.
//

import UIKit

enum MoveType {
    case copy
    case move
}


class ChangeFolderPlaceController: BaseViewController {

    var type = MoveType.move
    var controllerTag = 0
    var isRootPath = false
    var isNeedRequestShareList = false
    var isNeedRequestFileList = false

    var is_encryt = false
    
    //存储密钥的key
    var rootPasswordKey = ""
    //加密的根目录文件
    var encrytRootFile = FileModel()
    //解密输入框
    private var tipsTestFieldAlert: TipsTestFieldAlertView?
    
    private var isGetAllData = false//是否已获取服务器所有数据
    
    lazy var headerView = MoveHeaderView(tye: type).then {
        $0.backgroundColor = .white
    }
    
    lazy var bottomView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.shadowColor = UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.1).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 0);
        $0.layer.shadowOpacity = 1;
        $0.layer.shadowRadius = 5;
    }
    
    private lazy var filePathLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(12), type: .regular)
        $0.text = "根目录"
        $0.textColor = .custom(.gray_a2a7ae)
    }

    
    lazy var moveToHearBtn = Button().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
        if (type == .move){
            $0.setTitle("移动到此处", for: .normal)
        }else{
            $0.setTitle("复制到此处", for: .normal)
        }
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.clickCallBack = {[weak self] _ in
            guard let self = self else {return}
            self.moveFilesToCloud()
        }
    }
    
    lazy var createNewFolderBtn = Button().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(4)
        $0.layer.masksToBounds = true
        $0.setTitle("新建文件夹", for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.blue_427aed).cgColor
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    //PathCollectionView
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal//水平方向滚动
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

    }

    lazy var pathCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.frame = .zero
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self 
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.isScrollEnabled = false
        $0.register(PathCell.self, forCellWithReuseIdentifier: PathCell.reusableIdentifier)
    }

    lazy var encrytImgView = ImageView().then {
        $0.image = .assets(.encrypt_bg_icon)
        $0.contentMode = .scaleAspectFit
    }

    var currentPath = ""
    var currentPaths = [String]()
    var seletedFiles = [FileModel]()//选中的文件

    private var currentDatas : [FileModel]?
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(FileTableViewCell.self, forCellReuseIdentifier: FileTableViewCell.reusableIdentifier)

    }
    
    private var setNameView: SetNameAlertView?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isRootPath {
            let header = GIFRefreshHeader()
            tableView.mj_header = header
            tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(reload))
            if !isNeedRequestShareList {
                tableView.mj_footer = MJRefreshBackNormalFooter()
                tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(loadNextData))
            }
        }
        
        // MARK: - FunctionAction
        headerView.actionCallback = { tag in
            if tag == 1 {
                print("取消当前操作")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
               
        //是否为加密文件夹内
        encrytImgView.isHidden = (rootPasswordKey == "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        reload()
    }
    
    @objc private func reload() {
        currentDatas = nil
        isGetAllData = false
        tableView.mj_footer?.resetNoMoreData()
        getDiskData()
        
    }

    
    @objc private func loadNextData() {
        if isGetAllData {
            return
        }
        getDiskData()
    }


    
    private func getDiskData() {
        if isRootPath {//根目录
            let myFolder = FileModel()
            myFolder.name = "文件"
            myFolder.type = 0
            
            let shareFolder = FileModel()
            shareFolder.name = "共享文件"
            shareFolder.type = 0
            self.currentDatas = [myFolder, shareFolder]
            self.tableView.reloadData()
            
        }else{
            if isNeedRequestShareList == false {
                //存储的密码对象
                
                let pwdJsonStr:String = UserDefaults.standard.value(forKey: rootPasswordKey) as? String ?? ""
                let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
                
                var page: Int
                if let currentDatas = currentDatas {
                    page = (currentDatas.count / 30) + 1
                } else {
                    page = 1
                }
                
                
                
                NetworkManager.shared.fileList(path: currentPath, page: page, page_size: 30, pwd: pwdModel?.password ?? "") { [weak self] response in
                    guard let self = self else { return }
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_footer?.endRefreshing()
                    
                    print("请求成功")
                    //过滤掉所有非文件夹文件或无可读权限
                    let datas = response.list.filter({ (file:FileModel) -> Bool in
                        return file.type == 0 && file.read != 0
                    })
                    if self.currentDatas == nil {//下拉刷新 or 首次加载数据
                        self.tableView.mj_header?.endRefreshing()
                        self.currentDatas = datas
                        if response.list.count < 30 {
                            self.tableView.mj_footer?.isHidden = true
                        }else{
                            self.tableView.mj_footer?.isHidden = false
                        }
                        self.tableView.reloadData()
                    }else{//上拉加载更多数据
                        if !response.pager.has_more {//已无数据
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                            self.isGetAllData = true
                            return
                        }
                        self.isGetAllData = false
                        self.currentDatas! += datas
                        self.tableView.reloadData()
                    }

                } failureCallback: { code, err in
                    print("请求失败")
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_footer?.endRefreshing()
                    self.showToast("\(err)")
                    if code == 20009 {//密码错误
                        UserDefaults.standard.removeObject(forKey: self.rootPasswordKey)
//                        self.navigationController?.popViewController(animated: true)
                        if let count = self.navigationController?.viewControllers.count, count > 2, let vcs = self.navigationController?.viewControllers.prefix(2) {
                            
                            self.navigationController?.viewControllers = Array(vcs)
                        }
                    }
                }
            } else {
                
                var page: Int
                if let currentDatas = currentDatas {
                    page = (currentDatas.count / 30) + 1
                } else {
                    page = 1
                }
                
                NetworkManager.shared.shareFileList(page: page, page_size: 30) { [weak self] response in
                    guard let self = self else {return}
                    print("请求成功")
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_footer?.endRefreshing()
                    //过滤掉所有非文件夹文件
                    let datas = response.list.filter({ (file:FileModel) -> Bool in
                        return file.type == 0
                    })
                    
                    if self.currentDatas != nil {
                        self.currentDatas!.append(contentsOf: datas)
                    } else {
                        self.currentDatas = datas
                    }
                    
                    if !response.pager.has_more {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                    
                    self.tableView.reloadData()
                } failureCallback: { [weak self] code, err in
                    guard let self = self else { return }
                    print("请求失败")
                    self.tableView.mj_header?.endRefreshing()
                    self.showToast("\(err)")
                }

            }
        }
    }

    
    override func setupViews() {
        view.addSubview(headerView)
        view.addSubview(bottomView)
        if isRootPath || currentPaths.count == 1 {
            view.addSubview(filePathLabel)
            filePathLabel.text = currentPaths.first
            bottomView.isHidden = isRootPath
        }else{
            bottomView.isHidden = false
            if isNeedRequestFileList {
                bottomView.isHidden = true
            }else{
                if isNeedRequestShareList {
                    bottomView.isHidden = true
                }
            }
            view.addSubview(pathCollectionView)
        }
        bottomView.addSubview(createNewFolderBtn)
        bottomView.addSubview(moveToHearBtn)
        view.addSubview(encrytImgView)
        view.addSubview(tableView)
        
        
        createNewFolderBtn.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
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
                    self.showToast("新建文件夹成功".localizedString)
                } failureCallback: { [weak self] code, err in
                    LoadingView.hide()
                    guard let self = self else { return }
                    self.showToast(err)
                }

            }
        }
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height)
        }
        if isRootPath || currentPaths.count == 1 {
            filePathLabel.snp.makeConstraints {
                $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(5))
                $0.left.equalTo(ZTScaleValue(15))
                $0.right.equalTo(-ZTScaleValue(15))
                $0.height.equalTo(ZTScaleValue(30))
            }
            tableView.snp.makeConstraints {
                $0.top.equalTo(filePathLabel.snp.bottom).offset(ZTScaleValue(5))
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(bottomView.snp.top).offset(-ZTScaleValue(5))
            }

        }else{
            pathCollectionView.snp.makeConstraints {
                $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(5))
                $0.left.equalTo(ZTScaleValue(15))
                $0.right.equalTo(-ZTScaleValue(15))
                $0.height.equalTo(ZTScaleValue(30))
            }
            tableView.snp.makeConstraints {
                $0.top.equalTo(pathCollectionView.snp.bottom).offset(ZTScaleValue(5))
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(bottomView.snp.top).offset(-ZTScaleValue(5))
            }

        }

        
        bottomView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(Screen.tabbarHeight)
        }
        
        createNewFolderBtn.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX).multipliedBy(0.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(165))
            $0.height.equalTo(ZTScaleValue(40))
         }
         
         moveToHearBtn.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX).multipliedBy(1.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(165))
            $0.height.equalTo(ZTScaleValue(40))
         }
        
        encrytImgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(200))
        }

    }
    
    private func showCreatNewFolderView(){
        setNameView = SetNameAlertView(setNameType: .creatFile, currentName: "")
        SceneDelegate.shared.window?.addSubview(setNameView!)
    }

}

extension ChangeFolderPlaceController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPaths.count
    }
    
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathCell.reusableIdentifier, for: indexPath) as! PathCell
        cell.backgroundColor = .clear
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
        if indexPath.item == currentPaths.count - 1 {
            return
        }
        
        if (self.navigationController?.viewControllers.count)! >= indexPath.item {
            guard let vc = self.navigationController?.viewControllers[indexPath.item] else { return }
             self.navigationController?.popToViewController(vc, animated: true)
         }
    }

}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChangeFolderPlaceController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.reusableIdentifier, for: indexPath) as! FileTableViewCell
        cell.selectionStyle = .none
        if currentDatas?[indexPath.row].name == "" {
            currentDatas?[indexPath.row].name = AreaManager.shared.currentArea.name
        }
        cell.setModel(currentModel: currentDatas?[indexPath.row] ?? FileModel())
        cell.selectBtn.isHidden = true
        
        if ((currentDatas?[indexPath.row].is_encrypt) == 1) {
            cell.encryptImgView.isHidden = (rootPasswordKey != "")
        }
        //若选择移动的文件内存在此文件夹中，则置灰不允许点击
        if self.seletedFiles.filter({$0.id == currentDatas?[indexPath.row].id && $0.name == currentDatas?[indexPath.row].name}).count > 0 {
            cell.isUserInteractionEnabled = false
            cell.iconImgView.alpha = 0.5
            cell.fileNameLabel.alpha = 0.5
        }else{
            cell.isUserInteractionEnabled = true
            cell.iconImgView.alpha = 1
            cell.fileNameLabel.alpha = 1
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = currentDatas?[indexPath.row] ?? FileModel()
        //点击cell
        if isRootPath {//situation 1:根目录点击
            if indexPath.row == 0 {//文件
                if file.type == 0 {//文件夹
                    let vc = ChangeFolderPlaceController()
                    vc.currentPath = "/"
                    vc.isRootPath = false
                    vc.seletedFiles = seletedFiles
                    vc.isNeedRequestFileList = true
                    vc.type = type
                    let paths = currentPaths + ["文件"]
                    vc.currentPaths = paths
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                //共享文件夹
                let vc = ChangeFolderPlaceController()
                vc.isRootPath = false
                vc.seletedFiles = seletedFiles
                vc.isNeedRequestShareList = true
                vc.type = type
                let paths = currentPaths + ["共享文件"]
                vc.currentPaths = paths
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{//situation 1:并非根目录点击
            let file = currentDatas?[indexPath.row] ?? FileModel()
                if file.is_encrypt == 1 {
                    //加密文件
                    if self.rootPasswordKey == "" {//加密的根目录
                        
                        pushToFolder(file: file, isEncryt: true, isEncrytRoot: true)
                    }else{//非根目录
                        pushToFolder(file: file, isEncryt: true, isEncrytRoot: false)
                    }
                }else{
                   //非加密，直接请求下一个页面
                        pushToFolder(file: file, isEncryt: false, isEncrytRoot: false)
                }
        print("点击cell")
        }
    }
    
    private func pushToFolder(file:FileModel, isEncryt:Bool, isEncrytRoot:Bool){
        if isEncryt {//加密文件
            
            checkEncrytFolder(file: file, isEncrytRoot: isEncrytRoot) {
                //密码验证完成
                if isEncrytRoot {//加密文件的根目录
                    let vc = ChangeFolderPlaceController()
                    vc.type = self.type
                    vc.currentPath = file.path
                    vc.isRootPath = false
                    vc.rootPasswordKey = AreaManager.shared.currentArea.scope_token + file.path
                    vc.is_encryt = true
                    vc.encrytRootFile = file
                    vc.seletedFiles = self.seletedFiles
                    let paths = self.currentPaths + [file.name]
                    vc.currentPaths = paths
                    self.navigationController?.pushViewController(vc, animated: true)

                }else{//加密文件子目录
                    let vc = ChangeFolderPlaceController()
                    vc.type = self.type
                    vc.currentPath = file.path
                    let paths = self.currentPaths + [file.name]
                    vc.currentPaths = paths
                    vc.isRootPath = false
                    vc.rootPasswordKey = self.rootPasswordKey
                    vc.is_encryt = self.is_encryt
                    vc.encrytRootFile = self.encrytRootFile
                    vc.seletedFiles = self.seletedFiles
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }else{//非加密文件
            let vc = ChangeFolderPlaceController()
            vc.type = type
            vc.currentPath = file.path
            vc.isRootPath = false
            vc.seletedFiles = seletedFiles
            let paths = currentPaths + [file.name]
            vc.currentPaths = paths
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    private func checkEncrytFolder(file: FileModel , isEncrytRoot:Bool, complete:(()->())?){
        if isEncrytRoot {//根目录
            let key = AreaManager.shared.currentArea.scope_token + file.path
            let pwdJsonStr = UserDefaults.standard.value(forKey: key) as? String ?? ""
            let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
            if pwdModel == nil {
                self.tipsTestFieldAlert = TipsTestFieldAlertView.show(message: "请输入密码", sureCallback: {[weak self] pwd in
                    guard let self = self else {return}
                    print("密码是\(pwd)")
                    NetworkManager.shared.decryptFolder(name: file.path, password: pwd) { response in
                        //更新时间和密码
                        let pwdModel = PasswordModel()
                        pwdModel.password = pwd
                        //当前时间
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        pwdModel.saveTime = dateFormatter.string(from: Date())
                        let key = AreaManager.shared.currentArea.scope_token + file.path
                        UserDefaults.standard.setValue(pwdModel.toJSONString(prettyPrint:true), forKey: key)
                        complete?()
                    } failureCallback: { code, err in
                        //密码验证失败
                        self.showToast(err)
                    }
                })
            }else{
                complete?()
            }
        }else{//子目录
            let pwdJsonStr = UserDefaults.standard.value(forKey: rootPasswordKey) as? String ?? ""
            let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
            if pwdModel == nil {
                self.tipsTestFieldAlert = TipsTestFieldAlertView.show(message: "请输入密码", sureCallback: {[weak self] pwd in
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
                        let key = self.rootPasswordKey
                        UserDefaults.standard.setValue(pwdModel.toJSONString(prettyPrint:true), forKey: key)
                        complete?()
                    } failureCallback: { code, err in
                        //密码验证失败
                        self.showToast(err)
                    }
                })
            }else{
                complete?()
            }
        }
    }
    
}

extension ChangeFolderPlaceController{
    private func moveFilesToCloud(){
        var action = ""
        if type == .move {
            action = "move"
        }else{
            action = "copy"
        }
        var filePaths = [String]()
        for file in seletedFiles {
            filePaths.append(file.path)
        }
        
        let pwdJsonStr:String = UserDefaults.standard.value(forKey: rootPasswordKey) as? String ?? ""
        let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
        LoadingView.show()
        NetworkManager.shared.moveFiles(sources: filePaths, action: action, destination: currentPath, destination_pwd: pwdModel?.password ?? "") {[weak self] respond in
            guard let self = self else {return}
            print(respond.reason)
            LoadingView.hide()
            self.showToast(String(format: "%@成功", self.type == .move ? "移动":"复制"))
            self.navigationController?.dismiss(animated: true, completion: nil)
        } failureCallback: {[weak self] code, err in
            guard let self = self else {return}
            //系统提示“无权限”
            LoadingView.hide()
            self.showToast("\(err)")
        }

    }
}

