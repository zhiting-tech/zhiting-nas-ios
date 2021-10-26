//
//  MineSettingAlert.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/15.
//

import Foundation

// MARK: - MineSettingAlert
class MineSettingAlert: UIView {
    var selectCallback: ((_ item: Item) -> ())?

    var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedArea: Area {
        return AreaManager.shared.currentArea
    }

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
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.width.equalTo(ZTScaleValue(125))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.top.equalToSuperview().offset(Screen.k_nav_height + ZTScaleValue(10))
            $0.height.equalTo(50)
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

extension MineSettingAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineSettingAlertCell.reusableIdentifier, for: indexPath) as! MineSettingAlertCell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.icon.image = item.icon

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        selectCallback?(items[indexPath.row])
        removeFromSuperview()
    }
    
}



// MARK: - MineSettingAlertCell & Model
extension MineSettingAlert {
    struct Item {
        let title: String
        let icon: UIImage?
    }

    class MineSettingAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        
        lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(21.5)
                $0.left.equalToSuperview().offset(17)
                $0.height.width.equalTo(15)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.left.equalTo(icon.snp.right).offset(12.5)
                $0.right.equalToSuperview().offset(-4.5)
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
