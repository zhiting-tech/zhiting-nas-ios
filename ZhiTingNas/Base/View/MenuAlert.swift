//
//  MenuAlert.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/7/16.
//


import UIKit

// MARK: - MenuAlert
class MenuAlert: UIView {
    var selectCallback: ((_ item: Item) -> ())?

    var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var alertPoint = CGPoint.zero

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.clear
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
    
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(FolderMenuAlertCell.self, forCellReuseIdentifier: FolderMenuAlertCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.alwaysBounceVertical = false
        $0.showsVerticalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    deinit {
        if observationInfo != nil {
            tableView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(items: [Item], alertPoint: CGPoint) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.items = items
        self.alertPoint = alertPoint
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(tableView)
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.width.equalTo(ZTScaleValue(120))
            $0.left.equalToSuperview().offset(alertPoint.x)
            $0.top.equalToSuperview().offset(alertPoint.y)
            $0.height.equalTo(200)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change![.newKey] as? CGSize)?.height  else {
                return
            }
            
            let tableViewHeight = height + ZTScaleValue(100) > Screen.screenHeight ? Screen.screenHeight - ZTScaleValue(120) : height
            containerView.snp.updateConstraints {
                $0.height.equalTo(tableViewHeight)
            }

        }
    }

    @objc private func close() {
        removeFromSuperview()
    }


    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 1
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension MenuAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderMenuAlertCell.reusableIdentifier, for: indexPath) as! FolderMenuAlertCell
        cell.icon.image = items[indexPath.row].icon
        cell.titleLabel.text = items[indexPath.row].title

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectCallback?(items[indexPath.row])
        removeFromSuperview()
    }
    
}



// MARK: - FolderMenuAlertCell
extension MenuAlert {
    class FolderMenuAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.family_unsel)
        }
        
        lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "home"
        }


        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            
            icon.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.left.equalToSuperview().offset(17)
                $0.height.width.equalTo(15)
            }
            
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(14)
                $0.left.equalTo(icon.snp.right).offset(8)
                $0.right.equalToSuperview().offset(-4.5)
            }
            
            line.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(13)
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

extension MenuAlert {
    struct Item {
        let title: String
        let icon: UIImage?
    }
}
