//
//  FileShareController.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/24.
//

import UIKit

class FileShareController: BaseViewController {
    
    lazy var shareFileLabel = UILabel().then {
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(12), type: .medium)
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var shareToUsersLabel = UILabel().then {
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(12), type: .medium)
        $0.text = "共享给"
    }
    
    
    lazy var selectedAllLabel = UILabel().then {
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(12), type: .medium)
        $0.textAlignment = .right
        $0.text = "全选"
    }
    
    lazy var selectedAllBtn = Button().then {
        $0.setImage(.assets(.shareSelected_normal), for: .normal)
        $0.setImage(.assets(.shareSelected_selected), for: .selected)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.seletedAll()
        }

    }
    
    private lazy var sureButton = Button().then {
        $0.setTitle("确定".localizedString, for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            //发送共享请求
            self.shareFilesToCloud()
        }
    }

    
    //collectionview
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.itemSize = CGSize(width: ZTScaleValue(90), height:  ZTScaleValue(100))
        //行列间距
        $0.minimumLineSpacing = ZTScaleValue(15)
        $0.minimumInteritemSpacing = ZTScaleValue(10)
        //设置内边距
        $0.sectionInset = UIEdgeInsets(top: ZTScaleValue(0), left: ZTScaleValue(15), bottom: ZTScaleValue(0), right: ZTScaleValue(15))
    }

    lazy var fileCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.register(ShareFileCell.self, forCellWithReuseIdentifier: ShareFileCell.reusableIdentifier)
    }

    
    //tableview
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        //创建Cell
        $0.register(UserShareInfoCell.self, forCellReuseIdentifier: UserShareInfoCell.reusableIdentifier)

    }
    
    private var userDatas = [User]()
    var fileDatas = [FileModel]()
    private var seletedUsers = [User]()//选中的用户

    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        shareFileLabel.text = String(format: "共享文件(共%d个)", fileDatas.count)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "共享给"
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sureButton)
        
        getUsers()
    }
    
    override func setupViews() {
        view.addSubview(shareFileLabel)
        view.addSubview(fileCollectionView)
        view.addSubview(line)
        view.addSubview(shareToUsersLabel)
        view.addSubview(selectedAllLabel)
        view.addSubview(selectedAllBtn)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        shareFileLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(14) + Screen.k_nav_height)
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
        }
        
        if fileDatas.count < 3 {
            fileCollectionView.snp.makeConstraints {
                $0.top.equalTo(shareFileLabel.snp.bottom).offset(ZTScaleValue(5))
                $0.left.equalTo(ZTScaleValue(15))
                $0.right.equalTo(-ZTScaleValue(15))
                $0.height.equalTo(ZTScaleValue(100))
            }
        }else{
            fileCollectionView.snp.makeConstraints {
                $0.top.equalTo(shareFileLabel.snp.bottom).offset(ZTScaleValue(5))
                $0.left.equalTo(ZTScaleValue(15))
                $0.right.equalTo(-ZTScaleValue(15))
                $0.height.equalTo(ZTScaleValue(210))
            }
        }

        
        line.snp.makeConstraints {
            $0.top.equalTo(fileCollectionView.snp.bottom).offset(ZTScaleValue(15))
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        shareToUsersLabel.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(16.5))
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
        }
        
        selectedAllLabel.snp.makeConstraints {
            $0.centerY.equalTo(shareToUsersLabel)
            $0.right.equalTo(selectedAllBtn.snp.left).offset(-ZTScaleValue(10))
            $0.width.equalTo(ZTScaleValue(50))
        }
        selectedAllBtn.snp.makeConstraints {
            $0.centerY.equalTo(shareToUsersLabel)
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(16))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(shareToUsersLabel.snp.bottom).offset(ZTScaleValue(15))
            $0.left.right.bottom.equalToSuperview()
        }
        
    }

}

// MARK: - UICollectionViewDelegate && UICollectionViewDataSource
extension FileShareController:  UICollectionViewDelegate, UICollectionViewDataSource {
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileDatas.count
    }
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareFileCell.reusableIdentifier, for: indexPath) as! ShareFileCell

        let file = fileDatas[indexPath.item]
        if file.type == 0 {
            cell.iconView.image = .assets(.folder_middle)
        }else if file.type == 10{
            cell.iconView.image = .assets(.share_folder_middle)
        }
        cell.fileNameLabel.text = file.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let selectCallback = selectCallback else {
//            return
//        }
//        selectCallback(indexPath.item)
    }
}

 // MARK: - UITableViewDelegate && UITableViewDataSource
extension FileShareController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserShareInfoCell.reusableIdentifier, for: indexPath) as! UserShareInfoCell
        cell.selectionStyle = .none
        cell.setModel(currentModel: userDatas[indexPath.row])
        cell.selectBtn.tag = indexPath.row

        cell.selectBtn.clickCallBack = {[weak self] sender in
            guard let self = self else {
                return
            }
            let user: User = self.userDatas[sender.tag]
            self.clickUser(user: user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User = self.userDatas[indexPath.row]
        clickUser(user: user)
    }
}

extension FileShareController {
    
    private func clickUser(user: User){
        user.isSelected = !(user.isSelected ?? false)
        if user.isSelected ?? false {//选中
            seletedUsers.append(user)//添加选中目标
        }else{
            //删除取消选中对象
            seletedUsers.removeAll(where: { user.nickname == $0.nickname })
        }
        if seletedUsers.count == userDatas.count {
            selectedAllBtn.isSelected = true
        }else{
            selectedAllBtn.isSelected = false
        }
        tableView.reloadData()
    }
    
    @objc private func seletedAll(){
        selectedAllBtn.isSelected = !selectedAllBtn.isSelected
        seletedUsers.removeAll()
        if selectedAllBtn.isSelected {
            seletedUsers.removeAll()
            for (_, user) in userDatas.enumerated() {
                user.isSelected = true
                seletedUsers.append(user)
            }
        }else{
            for (_, user) in userDatas.enumerated() {
                user.isSelected = false
            }
        }
        tableView.reloadData()
    }

}


// MARK: - Network
extension FileShareController {
    private func getUsers() {
        NetworkManager.shared.saUserList(area: AreaManager.shared.currentArea) { [weak self] response in
            guard let self = self else { return }
            //处理筛选非本人用户
            self.userDatas = response.users.filter({ $0.user_id != AreaManager.shared.currentArea.sa_user_id })
            self.tableView.reloadData()

        } failureCallback: { [weak self] code, err in
            self?.showToast(err)
        }

    }
    
    private func shareFilesToCloud() {
        
        var filePaths = [String]()
        for file in fileDatas {
            filePaths.append(file.path)
        }
        
        if seletedUsers.count == 0 {
            return
        }
        
        
        let userIds = seletedUsers.map(\.user_id)
        let editMemberAlert = EditShareMemberAlert()
        editMemberAlert.set(members: seletedUsers)
        editMemberAlert.reSetBtn()
        //权限判断
        if self.fileDatas.filter({ $0.read == 0 }).count > 0 {//没有可读权限
            editMemberAlert.readBtn.isUserInteractionEnabled = false
            editMemberAlert.readBtn.alpha = 0.5
        } else {
            editMemberAlert.readBtn.isUserInteractionEnabled = true
            editMemberAlert.readBtn.alpha = 1
            editMemberAlert.readBtn.isSelected = true
        }
        
        if self.fileDatas.filter({ $0.write == 0 }).count > 0 {//没有写入权限
            editMemberAlert.writeBtn.isUserInteractionEnabled = false
            editMemberAlert.writeBtn.alpha = 0.5
        } else {
            editMemberAlert.writeBtn.isUserInteractionEnabled = true
            editMemberAlert.writeBtn.alpha = 1
        }
        
        if self.fileDatas.filter({ $0.deleted == 0 }).count > 0 {//没有删权限
            editMemberAlert.deleteBtn.isUserInteractionEnabled = false
            editMemberAlert.deleteBtn.alpha = 0.5
        } else {
            editMemberAlert.deleteBtn.isUserInteractionEnabled = true
            editMemberAlert.deleteBtn.alpha = 1
        }
        
        
        editMemberAlert.sureCallback = { [weak self] read, write, delete in
            guard let self = self else { return }
            LoadingView.show()
            NetworkManager.shared.shareFiles(paths: filePaths, usersId: userIds, read: read, write: write, delete: delete, fromUser: UserManager.shared.currentUser.nickname) { respond in
                SceneDelegate.shared.window?.makeToast("共享成功".localizedString)
                editMemberAlert.removeFromSuperview()
                LoadingView.hide()
                self.navigationController?.popViewController(animated: true)
                
            } failureCallback: { code, err in
                LoadingView.hide()
                SceneDelegate.shared.window?.makeToast("共享失败".localizedString)
            }
        }
        
        SceneDelegate.shared.window?.addSubview(editMemberAlert)
        
        
        
    }
}
