//
//  TransferDownloadFailAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/10/18.
//

import UIKit
import SwiftUI

class TransferDownloadFailAlert: UIView {
    var taskInfo: GoFileDownloadInfoModel?

    var fileList = [GoFileDownloadInfoModel]()

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(16), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.text = "下载失败列表".localizedString
    }
    
    private lazy var docIcon = ImageView().then {
        $0.image = .assets(.folder_icon)
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var docNameLabel = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .medium)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "文件夹".localizedString
    }
    
    private lazy var docStateLabel = UILabel().then {
        $0.font = .font(size: 11.ztScaleValue, type: .medium)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "共0个文件".localizedString
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    private lazy var tipsLabel = UILabel().then {
        $0.font = .font(size: 12.ztScaleValue, type: .medium)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "下载失败列表".localizedString
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.alwaysBounceVertical = false
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.register(TransferDownloadFailCell.self, forCellReuseIdentifier: TransferDownloadFailCell.reusableIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()
    }
    
    convenience init(task: GoFileDownloadInfoModel) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.taskInfo = task
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TransferDownloadFailAlert {
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(docIcon)
        containerView.addSubview(docNameLabel)
        containerView.addSubview(docStateLabel)
        containerView.addSubview(line)
        containerView.addSubview(tipsLabel)
        containerView.addSubview(tableView)
        
        

    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(500.ztScaleValue)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(16.5.ztScaleValue)
        }
        
        docIcon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(14.ztScaleValue)
            $0.height.equalTo(33.5.ztScaleValue)
            $0.width.equalTo(40.ztScaleValue)
            $0.top.equalTo(titleLabel.snp.bottom).offset(25.5)
        }
        
        docNameLabel.snp.makeConstraints {
            $0.top.equalTo(docIcon.snp.top)
            $0.left.equalTo(docIcon.snp.right).offset(17.5.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }
        
        docStateLabel.snp.makeConstraints {
            $0.top.equalTo(docNameLabel.snp.bottom)
            $0.left.equalTo(docIcon.snp.right).offset(17.5.ztScaleValue)
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.equalToSuperview().offset(14.ztScaleValue)
            $0.right.equalToSuperview().offset(-14.ztScaleValue)
            $0.top.equalTo(docIcon.snp.bottom).offset(19)
        }
        
        tipsLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(14.ztScaleValue)
            $0.top.equalTo(line.snp.bottom).offset(14.ztScaleValue)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight)
        }

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        getFileList()
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
     
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}


extension TransferDownloadFailAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransferDownloadFailCell.reusableIdentifier, for: indexPath) as! TransferDownloadFailCell
        let model = fileList[indexPath.row]
        cell.setDownloadModel(model: model)
        cell.btnCallback = { [weak self] in
            guard let self = self else { return }
            GoFileNewManager.shared.deleteDownloadTask(by: model)
            self.getFileList()
        }

        return cell
    }
    
}

extension TransferDownloadFailAlert {
    private func getFileList() {
        guard let task = taskInfo else { return }
        docNameLabel.text = task.name

        let total = GoFileNewManager.shared.getDownloadDirInfo(by: task)
        fileList = total.filter({ $0.status == 4 })
        tableView.reloadData()

        let attrStr = NSMutableAttributedString(string: "共",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.font(size: 11.ztScaleValue, type: .medium),
                                                    NSAttributedString.Key.foregroundColor: UIColor.custom(.gray_a2a7ae)
                                                 ])
        
        let attrStr2 = NSMutableAttributedString(string: "\(total.count)",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.font(size: 11.ztScaleValue, type: .medium),
                                                    NSAttributedString.Key.foregroundColor: UIColor.custom(.blue_427aed)
                                                 ])
        attrStr.append(attrStr2)
        
        
        let attrStr3 = NSMutableAttributedString(string: "个文件, ",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.font(size: 11.ztScaleValue, type: .medium),
                                                    NSAttributedString.Key.foregroundColor: UIColor.custom(.blue_427aed)
                                                 ])
        attrStr.append(attrStr3)
        
        let attrStr4 = NSMutableAttributedString(string: "\(fileList.count)",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.font(size: 11.ztScaleValue, type: .medium),
                                                    NSAttributedString.Key.foregroundColor: UIColor.custom(.red_fe0000)
                                                 ])
        attrStr.append(attrStr4)
        
        let attrStr5 = NSMutableAttributedString(string: "个下载失败",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.font(size: 11.ztScaleValue, type: .medium),
                                                    NSAttributedString.Key.foregroundColor: UIColor.custom(.gray_a2a7ae)
                                                 ])
        attrStr.append(attrStr5)
        
        docStateLabel.attributedText = attrStr

    }
}
