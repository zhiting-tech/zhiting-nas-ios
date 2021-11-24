//
//  AddMemberViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/6.
//

import UIKit


class AddMemberViewController: BaseViewController {
    /// 是否添加到私人文件夹
    var isPrivateFolder = false
    
    /// 保存回调
    var saveCallback: (([User]) -> ())?

    /// 之前已添加的成员
    var defaultSelectMembers = [User]()

    var members = [User]()
    
    /// 已选择成员
    var selectedMembers: [User] {
        return members
            .filter { ($0.isSelected ?? false) }
            .filter { member in
                !defaultSelectMembers.contains(where: { $0.user_id == member.user_id })
            }
    }

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "添加成员".localizedString
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        getMembers()
    }

    
    /// 保存按钮
    private lazy var saveBtn = UIButton().then {
        $0.titleLabel?.font = .font(size: 14, type: .bold)
        $0.setTitle("保存".localizedString, for: .normal)
        $0.setTitleColor(.custom(.black_3f4663), for: .normal)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSave)))
    }
    
    private lazy var emptyView = AddMemberEmptyView()
    
    private lazy var selectedTableViewHeader = AddMemberSectionHeader().then {
        $0.frame.size.height = 40
        $0.titleLabel.text = "已选择成员(\(members.count))"
    }
    
    /// 已选择成员tableView
    private lazy var selectedTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.register(AddMemberSelectedCell.self, forCellReuseIdentifier: AddMemberSelectedCell.reusableIdentifier)
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    
    private lazy var memberTableViewHeader = AddMemberSectionHeader().then {
        $0.titleLabel.text = "全部成员列表"
        $0.frame.size.height = 40
    }
    /// 全部成员列表tableView
    private lazy var memberTableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.showsVerticalScrollIndicator = false
        $0.register(AddMemberListCell.self, forCellReuseIdentifier: AddMemberListCell.reusableIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupViews() {
        view.addSubview(selectedTableView)
        view.addSubview(line)
        view.addSubview(memberTableView)
        view.addSubview(memberTableViewHeader)
        view.addSubview(selectedTableViewHeader)

    }
    
    override func setupConstraints() {
        let tableViewH: CGFloat = (view.bounds.height - 10) / 2 - 60.ztScaleValue - 40
        selectedTableViewHeader.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.height.equalTo(40)
        }

        selectedTableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(selectedTableViewHeader.snp.bottom)
            $0.height.equalTo(tableViewH)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(selectedTableView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }
        
        memberTableViewHeader.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }

        memberTableView.snp.makeConstraints {
            $0.top.equalTo(memberTableViewHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }


    }


}


extension AddMemberViewController {
    @objc
    private func tapSave() {

        if selectedMembers.count == 0 {
            showToast("请先选择成员".localizedString)
            return
        }
        
        if isPrivateFolder && (selectedMembers.count + defaultSelectMembers.count) > 1 {
            showToast("“私人文件夹”，则只能有一个成员".localizedString)
            return
        }

        
        saveCallback?(selectedMembers)
        navigationController?.popViewController(animated: true)
        
    }
    
    private func getMembers() {
        showLoading(.custom(.white_ffffff))
        NetworkManager.shared.saUserList(area: AreaManager.shared.currentArea) { [weak self] response in
            guard let self = self else { return }
            self.members = response.users
            self.selectedTableView.reloadData()
            self.memberTableView.reloadData()
            self.hideLoading()
        } failureCallback: { [weak self] code, err in
            self?.showToast(err)
            self?.hideLoading()
        }

    }
}


extension AddMemberViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == memberTableView {
            return members.count
        } else {
            selectedTableViewHeader.titleLabel.text = "已选择成员(\(selectedMembers.count))"
            if selectedMembers.count > 0 {
                emptyView.removeFromSuperview()
            } else {
                view.addSubview(emptyView)
                emptyView.snp.makeConstraints {
                    $0.top.equalTo(selectedTableViewHeader.snp.top)
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalTo(selectedTableView.snp.bottom)
                }
                
                if let loadingView = loadingView {
                    view.bringSubviewToFront(loadingView)
                }
            }
            return selectedMembers.count
        }

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == memberTableView {
            let cell = memberTableView.dequeueReusableCell(withIdentifier: AddMemberListCell.reusableIdentifier, for: indexPath) as! AddMemberListCell
            
            cell.member = members[indexPath.row]
            
            if defaultSelectMembers.contains(where: { $0.user_id == members[indexPath.row].user_id }) {
                cell.contentView.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5
                cell.selectIcon.image = .assets(.shareSelected_selected)
            } else {
                cell.contentView.isUserInteractionEnabled = true
                cell.contentView.alpha = 1
            }


            return cell

        } else {
            let cell = selectedTableView.dequeueReusableCell(withIdentifier: AddMemberSelectedCell.reusableIdentifier, for: indexPath) as! AddMemberSelectedCell
            
            cell.member = selectedMembers[indexPath.row]
            
            cell.readableBtn.selectCallback = { [weak self] isSelected in
                guard let self = self else { return }
                self.selectedMembers[indexPath.row].read = isSelected ? 1 : 0
                if !isSelected {
                    self.selectedMembers[indexPath.row].write = 0
                    self.selectedMembers[indexPath.row].deleted = 0
                }
                self.selectedTableView.reloadData()

            }
            
            cell.writableBtn.selectCallback = { [weak self] isSelected in
                guard let self = self else { return }
                self.selectedMembers[indexPath.row].write = isSelected ? 1 : 0
                if isSelected && self.selectedMembers[indexPath.row].read == 0 {
                    self.selectedMembers[indexPath.row].read = 1
                }
                self.selectedTableView.reloadData()
            }
            
            cell.deletableBtn.selectCallback = { [weak self] isSelected in
                guard let self = self else { return }
                self.selectedMembers[indexPath.row].deleted = isSelected ? 1 : 0
                if isSelected && self.selectedMembers[indexPath.row].read == 0 {
                    self.selectedMembers[indexPath.row].read = 1
                }
                self.selectedTableView.reloadData()
            }
            
            cell.cancelBtn.clickCallBack = { [weak self] _ in
                guard let self = self else { return }
                self.selectedMembers[indexPath.row].isSelected = false
                self.selectedTableView.reloadData()
                self.memberTableView.reloadData()
            }

            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == memberTableView {
            let member = members[indexPath.row]
            if isPrivateFolder && (selectedMembers.count + defaultSelectMembers.count) > 0 {
                showToast("“私人文件夹”，则只能有一个成员".localizedString)
                return
            }
            
            if !defaultSelectMembers.contains(where: { $0.user_id == member.user_id }) {
                member.isSelected = !(member.isSelected ?? false)
                member.read = 1
                member.write = isPrivateFolder ? 1 : 0
                member.deleted = isPrivateFolder ? 1 : 0
                memberTableView.reloadData()
                selectedTableView.reloadData()
            }
            
        }
    }

    
}
