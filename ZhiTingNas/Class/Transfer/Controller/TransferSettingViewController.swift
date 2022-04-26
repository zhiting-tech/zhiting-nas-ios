//
//  TransferSettingViewController.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/11/30.
//

import UIKit

class TransferSettingViewController: BaseViewController {
    @UserDefaultBool("allowCellular") private var allowCellular

    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 18, type: .bold)
        $0.text = "下载设置".localizedString
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
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 10))
        header.backgroundColor = .custom(.gray_f2f5fa)
        $0.tableHeaderView = header
    }
    
    
    private lazy var transferSettingCell = TransferSettingCell().then {
        $0.titleLabel.text = "传输设置".localizedString
        $0.detailLabel.text = "传输网络设置".localizedString
        $0.valueLabel.text = "允许使用流量上传/下载".localizedString
    }
    
    private lazy var transferSettingAlert = TransferSettingAlert()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        
        transferSettingCell.callback = { [weak self] in
            guard let self = self else { return }
            SceneDelegate.shared.window?.addSubview(self.transferSettingAlert)
        }
        
        transferSettingAlert.items = [
            .init(title: "仅WiFi环境上传/下载".localizedString, type: .wifi),
            .init(title: "允许使用流量上传/下载".localizedString, type: .cellular)
        ]
        
        if allowCellular {
            transferSettingAlert.selectedItem = .init(title: "允许使用流量上传/下载".localizedString, type: .cellular)
            self.transferSettingCell.valueLabel.text = "允许使用流量上传/下载".localizedString
        } else {
            transferSettingAlert.selectedItem = .init(title: "仅WiFi环境上传/下载".localizedString, type: .wifi)
            self.transferSettingCell.valueLabel.text = "仅WiFi环境上传/下载".localizedString
        }

        transferSettingAlert.selectCallback = { [weak self] item in
            guard let self = self else { return }
            self.transferSettingCell.valueLabel.text = item.title
            self.allowCellular = item.type == .cellular ? true : false
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransferSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return transferSettingCell
        
    }
    
    
}
