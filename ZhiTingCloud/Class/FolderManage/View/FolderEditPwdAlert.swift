//
//  FolderEditPwdAlert.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/16.
//

import UIKit

class FolderEditPwdAlert: UIView {
    var saveCallback: ((_ oldPwd: String, _ newPwd: String, _ confirmPwd: String) -> Void)?

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
        $0.text = "更改密码".localizedString
    }
    
    private lazy var closeButton = Button().then {
        $0.setTitle("取消", for: .normal)
        $0.setTitleColor(.custom(.black_333333), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var saveButton = Button().then {
        $0.setTitle("确定", for: .normal)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
        
    }
    
    private lazy var label1 = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.text = "旧密码".localizedString
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var label2 = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.text = "新密码".localizedString
        $0.textColor = .custom(.black_3f4663)
    }
    
    private lazy var label3 = UILabel().then {
        $0.font = .font(size: 14.ztScaleValue, type: .bold)
        $0.text = "确认新密码".localizedString
        $0.textColor = .custom(.black_3f4663)
    }

    
    private lazy var oldTextField = UITextField().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .left
        $0.clearButtonMode = .always
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.layer.cornerRadius = 10
        $0.isSecureTextEntry = true

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        $0.leftView = leftView
        $0.leftViewMode = .always
        
        
        
        $0.clearButtonMode = .always
        
        $0.placeholder = "请输入,不能少于6位"

    }
    
    private lazy var newTextField1 = UITextField().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .left
        $0.clearButtonMode = .always
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.layer.cornerRadius = 10
        $0.isSecureTextEntry = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        $0.leftView = leftView
        $0.leftViewMode = .always
        
        
        
        $0.clearButtonMode = .always
        $0.placeholder = "请输入,不能少于6位"
    }
    
    private lazy var newTextField2 = UITextField().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .left
        $0.clearButtonMode = .always
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.layer.cornerRadius = 10
        $0.isSecureTextEntry = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        $0.leftView = leftView
        $0.leftViewMode = .always
        
       
        
        $0.clearButtonMode = .always

        $0.placeholder = "请输入,不能少于6位"
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        setupViews()
        setupConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        closeButton.isEnhanceClick = true
        containerView.addSubview(saveButton)
        
        containerView.addSubview(oldTextField)
        containerView.addSubview(newTextField1)
        containerView.addSubview(newTextField2)
        
        containerView.addSubview(label1)
        containerView.addSubview(label2)
        containerView.addSubview(label3)
        
        saveButton.clickCallBack = { [weak self] _ in
            guard let self = self else {return}
            self.saveCallback?(self.oldTextField.text ?? "", self.newTextField1.text ?? "", self.newTextField2.text ?? "")
        }

    }
    
    func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(270.ztScaleValue)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.width.equalTo(ZTScaleValue(100))
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.left.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.width.equalTo(ZTScaleValue(30))
        }
        
        saveButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-ZTScaleValue(16.5))
            $0.width.equalTo(ZTScaleValue(30))
        }
        
        oldTextField.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
            $0.width.equalTo(250.ztScaleValue)
            $0.top.equalTo(titleLabel.snp.bottom).offset(25.ztScaleValue)
        }
        
        label1.snp.makeConstraints {
            $0.centerY.equalTo(oldTextField.snp.centerY)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }

        newTextField1.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
            $0.width.equalTo(250.ztScaleValue)
            $0.top.equalTo(oldTextField.snp.bottom).offset(15)
        }
        
        label2.snp.makeConstraints {
            $0.centerY.equalTo(newTextField1.snp.centerY)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }
        
        newTextField2.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15.ztScaleValue)
            $0.height.equalTo(50)
            $0.width.equalTo(250.ztScaleValue)
            $0.top.equalTo(newTextField1.snp.bottom).offset(15)
        }
        
        label3.snp.makeConstraints {
            $0.centerY.equalTo(newTextField2.snp.centerY)
            $0.left.equalToSuperview().offset(15.ztScaleValue)
        }

    }

    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        containerView.isHidden = true
        self.oldTextField.becomeFirstResponder()

        
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
    
    private func dismissWithCallback(idx: Int) {
        self.endEditing(true)
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            weakSelf?.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }, completion: { isFinished in
            if isFinished {
//                weakSelf?.selectCallback?(idx)
                super.removeFromSuperview()
            }
        })
    }
    
    @objc private func keyboardHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.remakeConstraints {
                $0.bottom.equalToSuperview().offset(10)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.height.equalTo(ZTScaleValue(360))
            }
            self.layoutIfNeeded()
        }
    }

    
    @objc func keyBoardWillShow(note: NSNotification) {
        //1
        let userInfo  = note.userInfo! as NSDictionary
        //2
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        //4
        let deltaY = keyBoardBounds.size.height
        //5
        let animations:(() -> Void) = {
            self.containerView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
        }
        
        containerView.isHidden = false
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
}
