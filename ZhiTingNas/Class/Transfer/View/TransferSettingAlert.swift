//
//  TransferSettingAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/11/30.
//

import Foundation
import UIKit

// MARK: - TransferSettingAlert
class TransferSettingAlert: UIView {
    var selectCallback: ((_ item: Item) -> ())?

    var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedItem: Item? {
        didSet {
            tableView.reloadData()
        }
    }

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 8
        $0.layer.shadowOffset = CGSize(width: -0.1, height: -0.1)
        
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .font(size: 14, type: .medium)
        $0.textAlignment = .center
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "传输网络设置".localizedString
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(MineSettingAlertCell.self, forCellReuseIdentifier: MineSettingAlertCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.alwaysBounceVertical = false
        $0.showsVerticalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    deinit {
        if tableView.observationInfo != nil {
            tableView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(line)
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19.5)
            $0.left.right.equalToSuperview()
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17.5)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.height.equalTo(100)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + Screen.bottomSafeAreaHeight
            tableView.snp.remakeConstraints {
                $0.height.equalTo(tableViewHeight)
                $0.top.equalTo(line.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight)
            }

        }
    }

    @objc private func close() {
        removeFromSuperview()
    }


    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: Screen.screenHeight / 2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = .identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: Screen.screenHeight / 2)
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension TransferSettingAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineSettingAlertCell.reusableIdentifier, for: indexPath) as! MineSettingAlertCell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.titleLabel.textColor = item.title == selectedItem?.title ? .custom(.blue_427aed) : .custom(.black_3f4663)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedItem = items[indexPath.row]
        tableView.reloadData()
        selectCallback?(items[indexPath.row])
        removeFromSuperview()
    }
    
}



// MARK: - MineSettingAlertCell & Model
extension TransferSettingAlert {
    struct Item {
        enum ItemType {
            case wifi
            case cellular
        }
        let title: String
        let type: ItemType
    }

    class MineSettingAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 14, type: .bold)
            $0.textAlignment = .center
            $0.textColor = .custom(.black_3f4663)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.left.right.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
            
            line.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(23)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
