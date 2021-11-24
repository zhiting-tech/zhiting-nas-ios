//
//  AddPartitionController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/7/5.
//

import UIKit

enum PartitionType {
    case add
    case edit
}

class AddPartitionController: BaseViewController {
    
    var currentType = PartitionType.add
    var currentModel = LogicVolume()
    var currentStoragePoolName = ""
    var originCapacityText = ""
    var originUnitText = ""
    
    private lazy var headerView = EditPartitionHeaderView(type: currentType).then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "名称"
    }
    
    private lazy var nameTextFiled = UITextField().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.backgroundColor = .custom(.gray_eeeff2)
        $0.delegate = self
        $0.tag = 1
        $0.placeholder = "请输入"
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: ZTScaleValue(15), height: ZTScaleValue(1))))
        $0.becomeFirstResponder()
        $0.leftViewMode = .always
    }
    
    private lazy var capacityLabel = UILabel().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "容量"
    }
    
    private lazy var capacityBackgroundView = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeff2)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
    }

    
    private lazy var capacityTextFiled = UITextField().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.backgroundColor = .custom(.gray_eeeff2)
        $0.delegate = self
        $0.tag = 2
        $0.placeholder = "请输入"
        $0.keyboardType = .numberPad
//        $0.layer.cornerRadius = ZTScaleValue(10)
//        $0.layer.masksToBounds = true
//        $0.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: ZTScaleValue(15), height: ZTScaleValue(1))))
        $0.leftViewMode = .always
    }
    
    private lazy var capacityMBLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "4 *"
    }
    
    private lazy var capacityMBLabel2 = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "= "
    }


    
    private lazy var capacityButton = Button().then {
        $0.frame = CGRect(x: 0, y: 0, width: ZTScaleValue(50), height: ZTScaleValue(50))
        $0.setTitle("GB", for: .normal)
        $0.imagePosition(style: .right, spacing: ZTScaleValue(8))
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.setImage(.assets(.icon_capacityArrow), for: .normal)
    }
    
    private lazy var saveButton = Button().then {
        $0.backgroundColor = .custom(.blue_427aed)
        $0.setTitle("保存 ", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.5
        $0.addTarget(self, action: #selector(saveButtonAction(sender:)), for: .touchUpInside)
    }
    
    private lazy var capacityMBDescriptLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.textColor = .custom(.gray_a2a7ae)
        $0.text = "* 分区容量只能设置为4MB的正整数倍数"
    }

    
    private lazy var partitionTableView = PartitionTableView(items: ["MB","GB","T"]).then {
        $0.backgroundColor = .clear
    }
        
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.actionCallback = {[weak self] action in
            guard let self = self else {return}
            switch action {
            case 0:
                self.navigationController?.popViewController(animated: true)
            case 1:
                print("删除")
                let tipsAlert = TipsAlertView(title: "删除确认", detail: "确定删除该分区吗？删除需要一些时间处 理，且删除后，该分区下的所有文件/文件 夹都全部删除。", warning: "操作不可撤销，请谨慎操作！", sureBtnTitle: "确定删除")
                tipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }

                    tipsAlert.sureBtn.buttonState = .waiting
                    NetworkManager.shared.deletePartition(name: self.currentModel.name, pool_name: self.currentStoragePoolName) {[weak self] response in
                        guard let self = self else {return}
                        tipsAlert.sureBtn.buttonState = .normal
                        tipsAlert.removeFromSuperview()
                        //弹框提示后台处理
                        let singleTipsAlert = SingleTipsAlertView(detail: "正在删除分区，已为您后台运行，可返回 列表刷新查看。", detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                        singleTipsAlert.sureCallback = { [weak self] in
                            guard let self = self else { return }
                            singleTipsAlert.removeFromSuperview()
                            self.navigationController?.popViewController(animated: true)
                        }
                        SceneDelegate.shared.window?.addSubview(singleTipsAlert)
                    } failureCallback: {[weak self] code, err in
                        guard let self = self else {return}
                        tipsAlert.sureBtn.buttonState = .normal
                        self.showToast(err)
                        
                    }
                }
                SceneDelegate.shared.window?.addSubview(tipsAlert)
            default:
                break
            }
        }
        
        if self.currentType == .edit {
            nameTextFiled.text = currentModel.name
            seperaterCapacity(size: currentModel.capacity)
        }else{
            changeUIWith(unit: "GB", value: "")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func setupViews() {
        view.addSubview(headerView)
        view.addSubview(nameLabel)
        view.addSubview(nameTextFiled)
        view.addSubview(capacityLabel)
        view.addSubview(capacityBackgroundView)
        capacityBackgroundView.addSubview(capacityMBLabel)
        capacityBackgroundView.addSubview(capacityMBLabel2)
        capacityBackgroundView.addSubview(capacityTextFiled)
        capacityBackgroundView.addSubview(capacityButton)
        view.addSubview(capacityMBDescriptLabel)
        capacityButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(Screen.k_nav_height)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(ZTScaleValue(50))
            $0.left.equalTo(ZTScaleValue(35))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalTo(ZTScaleValue(13))
        }
        
        nameTextFiled.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(20))
            $0.right.equalTo(-ZTScaleValue(42.5))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        capacityLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(ZTScaleValue(57.5))
            $0.left.equalTo(ZTScaleValue(35))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalTo(ZTScaleValue(13))
        }
        
        capacityBackgroundView.snp.makeConstraints {
            $0.centerY.equalTo(capacityLabel)
            $0.left.equalTo(nameLabel.snp.right).offset(ZTScaleValue(20))
            $0.right.equalTo(-ZTScaleValue(42.5))
            $0.height.equalTo(ZTScaleValue(50))
        }
        
        capacityMBDescriptLabel.snp.makeConstraints {
            $0.top.equalTo(capacityBackgroundView.snp.bottom).offset(ZTScaleValue(10))
            $0.left.right.equalTo(capacityBackgroundView)
        }
        
        capacityMBLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(16.ztScaleValue)
            $0.width.equalTo(25.ztScaleValue)
        }
        
        capacityMBLabel2.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(capacityMBLabel.snp.right).offset(65.ztScaleValue)
            $0.right.equalTo(capacityButton.snp.left).offset(-10.ztScaleValue)
        }
        
        capacityButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalToSuperview().offset(-5.ztScaleValue)
            $0.width.equalTo(50.ztScaleValue)
        }
        
        capacityTextFiled.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(capacityMBLabel.snp.right).offset(5.ztScaleValue)
            $0.right.equalTo(capacityMBLabel2.snp.left).offset(-5.ztScaleValue)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(capacityTextFiled.snp.bottom).offset(ZTScaleValue(85))
            $0.left.equalTo(ZTScaleValue(42.5))
            $0.right.equalTo(-ZTScaleValue(42.5))
            $0.height.equalTo(ZTScaleValue(50))
        }
    }
    
    private func seperaterCapacity(size:Int){
        var convertedValue = size
        var multiplyFactor = 0
        let tokens = ["B", "KB", "MB", "GB", "T", "PB",  "EB",  "ZB", "YB"]
        while convertedValue >= 1024 && (convertedValue % 1024 == 0) {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        
        let value = convertedValue
        let unit = tokens[multiplyFactor]
        
        self.changeUIWith(unit: unit, value: String(format: "%d", value))
        
        originCapacityText = String(format: "%d", value)
        originUnitText = unit
    }
    
    
    
}

extension AddPartitionController {
    
    @objc func buttonAction(sender: Button){
        print("点击内存单位切换")
        view.endEditing(true)
        partitionTableView.currentCapacity = sender.titleLabel?.text ?? ""
        view.addSubview(partitionTableView)
        partitionTableView.reload()
        partitionTableView.selectCallback = {[weak self] capacity in
            guard let self = self else {
                return
            }
            if capacity == sender.titleLabel?.text {
                return
            }
            self.saveButton.alpha = 0.5
            self.saveButton.isUserInteractionEnabled = false
            self.changeUIWith(unit: capacity, value: "" )
        }
        
    }
    
    private func changeUIWith(unit:String,value:String){
        if unit == "MB" {//MB样式
            let valueInt = Int((Double(value) ?? 0)/4.0)
            capacityTextFiled.placeholder = "请输入"
            if valueInt != 0 {
                capacityTextFiled.text = String(format: "%d", valueInt)
                capacityMBLabel2.text = String(format: "= %d", 4*valueInt)
            }else{
                capacityTextFiled.text = ""
                capacityMBLabel2.text = "= "
            }

            capacityMBLabel.isHidden = false
            capacityMBLabel2.isHidden = false
            capacityMBDescriptLabel.isHidden = false
            capacityTextFiled.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(capacityMBLabel.snp.right).offset(5.ztScaleValue)
                $0.right.equalTo(capacityMBLabel2.snp.left).offset(-5.ztScaleValue)
            }

        }else{//其他样式
            capacityMBLabel.isHidden = true
            capacityMBLabel2.isHidden = true
            capacityMBDescriptLabel.isHidden = true
            capacityTextFiled.placeholder = "请输入"
            capacityTextFiled.text = value
            capacityTextFiled.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.equalToSuperview().offset(10.ztScaleValue)
                $0.right.equalTo(capacityButton.snp.left).offset(-10.ztScaleValue)
            }
        }
        capacityButton.setTitle(unit, for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc func saveButtonAction(sender: Button){
        print("点击保存")
        view.endEditing(true)
        LoadingView.show()
        
        var capacity = capacityTextFiled.text?.replacingOccurrences(of: " ", with: "") ?? "0"
        if capacityButton.titleLabel?.text == "MB" {
            capacity = String(format: "%d", 4*Int(Double(capacity) ?? 0))
        }

        if currentType == .edit {//编辑
            judgeInfoChange(editName: nameTextFiled.text ?? "", editCapacity: capacity, unit: capacityButton.titleLabel?.text ?? "GB") {[weak self]
                capacityChanged, nameChanged, allowCapacity in
                 
                guard let self = self else {return}
                
                if allowCapacity == 2 {
                    LoadingView.hide()
                    self.showToast("分区内存不能减少")
                    return
                }
                
                if capacityChanged == 0 && nameChanged == 0{
                    LoadingView.hide()
                    self.showToast("未修改任何内容")
                    return
                }
                
                //保存编辑内容
                NetworkManager.shared.editPartition(name: self.currentModel.name, new_name: self.nameTextFiled.text ?? "", pool_name: self.currentStoragePoolName, capacity: Float(capacity) ?? 0, unit: self.capacityButton.titleLabel?.text ?? "GB") {[weak self] response in
                    LoadingView.hide()
                    var showText = ""
                    if nameChanged == 1 && capacityChanged == 0 {//仅编辑名称
                        showText = "保存成功"
                    }else{
                        showText = "正在保存分区信息，需要一些时间处理,已为您后台运行，可返回列表刷新查看。"
                    }
                    
                    let singleTipsAlert = SingleTipsAlertView(detail: showText, detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                    singleTipsAlert.sureCallback = { [weak self] in
                        guard let self = self else { return }
                        singleTipsAlert.removeFromSuperview()
                        self.navigationController?.popViewController(animated: true)
                    }
                    SceneDelegate.shared.window?.addSubview(singleTipsAlert)

                } failureCallback: {[weak self] code, err in
                    LoadingView.hide()
                    self?.showToast(err)
                }
                
            }


        } else if currentType == .add {//新增
            NetworkManager.shared.addPartition(name: nameTextFiled.text ?? "", capacity: Float(capacity) ?? 0, unit: capacityButton.titleLabel?.text ?? "GB", pool_name: currentStoragePoolName) {[weak self] response in
                LoadingView.hide()
                let singleTipsAlert = SingleTipsAlertView(detail: "正在保存分区信息，预计需要一些时间处理,已为您后台运行,可返回列表刷新查看", detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                singleTipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    singleTipsAlert.removeFromSuperview()
                    self.navigationController?.popViewController(animated: true)
                }
                SceneDelegate.shared.window?.addSubview(singleTipsAlert)
                
            } failureCallback: {[weak self] code, err in
                LoadingView.hide()
                self?.showToast(err)
            }

        }
        
    }
    
    private func judgeInfoChange(editName:String, editCapacity: String, unit: String, complete:( (_ capacityChanged: Int, _ nameChanged: Int, _ capacityIsAllowed: Int)->())?){
        var capacity: Double = 0
        var originC: Double = 0
        if unit == "MB" {
            capacity = (Double(editCapacity) ?? 0) * 1024
        }else if unit == "GB"{
            capacity = (Double(editCapacity) ?? 0) * 1024 * 1024
        }else{
            capacity = (Double(editCapacity) ?? 0) * 1024 * 1024 * 1024
        }
        
        if originUnitText == "MB" {
            originC = (Double(originCapacityText) ?? 0) * 1024
        }else if originUnitText == "GB" {
            originC = (Double(originCapacityText) ?? 0) * 1024 * 1024
        }else{
            originC = (Double(originCapacityText) ?? 0) * 1024 * 1024 * 1024
        }
        var capacityChanged = 0
        var nameChanged = 0
        var capacityIsAllowed = 0
        
        
        if originC != capacity {//表示内存大小已编辑
            capacityChanged = 1
            if capacity < originC {//不能减少内存，只能增加内存
                capacityIsAllowed = 2
            }
        }
        
        if currentModel.name != editName {//表示名称已修改
            nameChanged = 1
        }
                
        complete?(capacityChanged,nameChanged,capacityIsAllowed)
    }
    
}

extension AddPartitionController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if nameTextFiled.text?.count == 0 || capacityTextFiled.text?.count == 0 {
            saveButton.alpha = 0.5
            saveButton.isUserInteractionEnabled = false
        }else{
            saveButton.alpha = 1
            saveButton.isUserInteractionEnabled = true
        }
        
        if textField.tag == capacityTextFiled.tag {
            //不能以0开头
            if capacityTextFiled.text?.count == 1 && capacityTextFiled.text == "0" {
                capacityTextFiled.text = ""
            }
            
            
            if capacityButton.titleLabel?.text == "MB" {
                if capacityTextFiled.text?.count ?? 0 > 6{//限制MB仅能输入6位数
                    capacityTextFiled.text = String(textField.text!.prefix(6))
                }
                if capacityTextFiled.text == "" {
                    capacityMBLabel2.text = "= "
                }else{
                    capacityMBLabel2.text = String(format: "= %d", Int(4*(Double(capacityTextFiled.text ?? "0") ?? 0)))
                }
                
            }
        }
    }
}
