//
//  BackupManageViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/12/16.
//

import UIKit

class BackupManageViewController: BaseViewController {
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "自动备份设置".localizedString
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
    
    private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = 50
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.register(BackupManageCell.self, forCellReuseIdentifier: BackupManageCell.reusableIdentifier)
        $0.register(BackupManageSectionHeader.self, forHeaderFooterViewReuseIdentifier: BackupManageSectionHeader.reusableIdentifier)
        $0.sectionFooterHeight = 0
        $0.estimatedSectionFooterHeight = 0
    }
    
    lazy var photoCell = BackupManageCell().then {
        $0.icon.image = .assets(.icon_backup_photo)
        $0.titleLabel.text = "相册自动备份".localizedString
        $0.switchBtn.offColor = .custom(.gray_eeeeee)
        $0.switchBtn.setIsOn(UserManager.shared.allowPhotoBackups)
        
    }
    
    lazy var videoCell = BackupManageCell().then {
        $0.icon.image = .assets(.icon_backup_video)
        $0.titleLabel.text = "视频自动备份".localizedString
        $0.switchBtn.offColor = .custom(.gray_eeeeee)
        $0.switchBtn.setIsOn(UserManager.shared.allowVideoBackups)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        photoCell.switchBtn.stateChangeCallback = { state in
            if state {
                UserManager.shared.allowPhotoBackups = true
                SceneDelegate.shared.backupMedia()
            } else {
                UserManager.shared.allowPhotoBackups = false
                GoFileManager.shared.closePhotoBackups()
            }
        }
        
        videoCell.switchBtn.stateChangeCallback = { state in
            if state {
                UserManager.shared.allowVideoBackups = true
                SceneDelegate.shared.backupMedia()
            } else {
                UserManager.shared.allowVideoBackups = false
                GoFileManager.shared.closeVideoBackups()
            }
            
        }

    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension BackupManageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BackupManageSectionHeader.reusableIdentifier) as! BackupManageSectionHeader
        if section == 0 {
            header.label.text = "自动备份".localizedString
        } else {
            header.label.text = ""
        }

        return header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 0
        }
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return photoCell
            } else {
                return videoCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}
