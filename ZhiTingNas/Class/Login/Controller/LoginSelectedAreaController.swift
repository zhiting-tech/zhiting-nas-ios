//
//  LoginSelectedAreaController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/12/13.
//

import UIKit

class LoginSelectedAreaController: BaseViewController {

    var complete: ((AreasTokenModel)->())?
    
    var areas = [AreasTokenModel]()
    
    var currentSelectedRow = 0
        
    private lazy var emptyView = FileEmptyView().then {
        $0.label.text = "暂无可选择的家庭/公司"
    }

    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableview = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(AuthItemCell.self, forCellReuseIdentifier: AuthItemCell.reusableIdentifier)
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
    }
    
    lazy var sureBtn = Button().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.titleLabel?.tintColor = .custom(.white_ffffff)
        $0.titleLabel?.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.setTitle("确定", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "请选择家庭/公司"
        
        sureBtn.clickCallBack = {[weak self] _ in
            guard let model = self?.areas[self?.currentSelectedRow ?? 0] else {
                return
            }
            self?.complete?(model)
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func setupViews() {
        view.addSubview(line)
        view.addSubview(tableview)
        view.addSubview(sureBtn)
        tableview.addSubview(emptyView)
        sureBtn.isHidden = (areas.count == 0)
        emptyView.isHidden = !(areas.count == 0)
            

    }

    override func setupConstraints() {
        line.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.5.ztScaleValue)
        }
        
        sureBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10.ztScaleValue)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - 30.ztScaleValue)
            $0.height.equalTo(50.ztScaleValue)
        }
        
        tableview.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(sureBtn.snp.top).offset(-10.ztScaleValue)
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
            $0.height.equalTo(ZTScaleValue(110))
        }
    }
    

}

extension LoginSelectedAreaController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.ztScaleValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuthItemCell.reusableIdentifier, for: indexPath) as! AuthItemCell
        for i in 0 ..< areas.count {
            if i == currentSelectedRow {
                areas[i].isSelected = true
            }else{
                areas[i].isSelected = false
            }
        }
        cell.authItem = areas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedRow = indexPath.row
        tableview.reloadData()
    }
    
}
