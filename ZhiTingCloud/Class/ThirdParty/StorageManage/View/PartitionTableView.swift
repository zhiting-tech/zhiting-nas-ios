//
//  PartitionTableView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/7/5.
//

import UIKit


class PartitionTableView: UIView {
    var selectCallback: ((_ capacity: String) -> ())?
    var capacityItems = [String]()
    var currentCapacity = ""
    
    
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
        
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.separatorColor = .custom(.gray_eeeeee)
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    convenience init(items: [String], callback: ((_ capacity: String) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        capacityItems = items
        self.tableView.reloadData()
        self.selectCallback = callback
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reload(){
        tableView.reloadData()
    }
    
    private func setupViews() {

        addSubview(coverView)
        addSubview(containerView)

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
            $0.height.equalTo(ZTScaleValue(160))
        }
        
        tableView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(10.ztScaleValue)
        }


    }
}

extension PartitionTableView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capacityItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = capacityItems[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        if capacityItems[indexPath.row] == currentCapacity {
            cell.textLabel?.textColor = .custom(.blue_427aed)
        }else{
            cell.textLabel?.textColor = .custom(.black_3f4663)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismissWithCallback(capacity: capacityItems[indexPath.row])
    }

}

extension PartitionTableView{
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
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

    private func dismissWithCallback(capacity: String) {
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            weakSelf?.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
                weakSelf?.selectCallback?(capacity)
                super.removeFromSuperview()
            }
        })
    }
    

}
