//
//  SetNameAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/21.
//

import UIKit

enum SetNameType {
    /// 创建文件夹
    case creatFile
    /// 修改文件夹
    case resetName(isFile: Bool)
    /// 创建存储池
    case createStoragePool
    /// 修改存储池名称
    case resetStoragePoolName
}

class SetNameAlertView: UIView {
    var type: SetNameType = .creatFile
    
    var setNameCallback: ((_ name: String) -> ())?
    
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
        $0.setTitle("完成", for: .normal)
        $0.setTitleColor(.custom(.blue_2da3f6), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else {return}
            guard let setNameCallback = self.setNameCallback  else {
                return
            }
            if self.textField.text == "" {
                setNameCallback("")
            }else{
                setNameCallback(self.textField.text!)
            }
//            self.removeFromSuperview()
        }
    }
    
    private lazy var fileIconImgView = ImageView().then {
        $0.image = .assets(.folder_big)
        $0.contentMode = .scaleAspectFit
    }

    private lazy var textField = UITextField().then {
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
        $0.clearButtonMode = .always
        $0.backgroundColor = .custom(.gray_eeeeee)
        $0.delegate = self
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(setNameType: SetNameType,currentName: String, callback: ((_ name: String) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.fileIconImgView.image = ZTCTool.fileImageBy(fileName: currentName)
        self.type = setNameType
        switch setNameType {
        case .creatFile:
            self.titleLabel.text = "新建文件夹"
            self.textField.placeholder = "输入文件夹名称"
            self.textField.text = ""
            self.fileIconImgView.image = .assets(.folder_icon)
        case .resetName(let isFile) :
            self.titleLabel.text = "重命名"
            self.textField.text = currentName
            self.textField.placeholder = "输入名称"
            if !isFile {
                self.fileIconImgView.image = .assets(.folder_icon)
            }
        
        case .createStoragePool:
            self.titleLabel.text = "添加到新的存储池"
            self.fileIconImgView.image = .assets(.icon_storagePool)
            self.textField.text = currentName
            self.textField.placeholder = "输入新的存储池名称"
            
        case .resetStoragePoolName:
            self.titleLabel.text = "修改名称"
            self.fileIconImgView.image = .assets(.icon_storagePool)
            self.textField.text = currentName
            self.textField.placeholder = "输入名称"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupViews(){
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        closeButton.isEnhanceClick = true
        
        containerView.addSubview(saveButton)
        containerView.addSubview(fileIconImgView)
        containerView.addSubview(textField)
    }
    
    private func setConstrains(){
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(360))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.width.equalTo(ZTScaleValue(140))
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
        
        fileIconImgView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(50))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(118))
            $0.height.equalTo(ZTScaleValue(100))
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(fileIconImgView.snp.bottom).offset(ZTScaleValue(32))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(50))
        }
    }

    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        containerView.isHidden = true
        self.textField.becomeFirstResponder()

        
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
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
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

extension SetNameAlertView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch  type{
        case .createStoragePool, .resetStoragePoolName:
            if let text = textField.text, text.count > 50 {
                self.textField.text = String(text.prefix(50))
            }
        default:
            if let text = textField.text, text.count > 255 {
                self.textField.text = String(text.prefix(255))
            }
        }
        
        
    }
}
