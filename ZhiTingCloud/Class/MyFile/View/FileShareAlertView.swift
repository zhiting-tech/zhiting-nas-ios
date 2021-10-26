//
//  FileShareAlertView.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/24.
//

import UIKit

class FileShareAlertView: UIView {

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
    
    //fileInfo
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.myFile_tab)
    }
    
    lazy var fileNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    lazy var timeLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(11), type: .medium)
    }
    
    lazy var sizeLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(11), type: .medium)
    }
    
    lazy var line = UIView().then{
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, callback: ((_ index: Int) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.titleLabel.text = title

    }

    public func setCurrentFileModel(file: FileModel){
        if file.type == 0 {
            iconImgView.image = .assets(.folder_icon)
        }else{
            iconImgView.image = ZTCTool.fileImageBy(fileName: file.name)
        }
        
        fileNameLabel.text = file.name
        timeLabel.text = TimeTool.timeIntervalChangeToTimeStr(timeInterval: Double(file.mod_time), "yyyy-MM-dd")
        sizeLabel.text = String(format: "%d", file.size)
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        closeButton.isEnhanceClick = true
        
        containerView.addSubview(iconImgView)
        containerView.addSubview(fileNameLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(sizeLabel)
        containerView.addSubview(line)
        
        containerView.addSubview(tableView)
    }
    
    private func setupConstraints(){
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(430))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(16.5))
            $0.width.equalTo(ZTScaleValue(100))
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(30))
        }
        
        //Info
        iconImgView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(18.5))
            $0.width.height.equalTo(ZTScaleValue(40))
        }
        
        fileNameLabel.snp.makeConstraints {
            $0.top.equalTo(iconImgView)
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(18))
            $0.width.greaterThanOrEqualTo(ZTScaleValue(100))
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(iconImgView)
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(18))
            $0.width.lessThanOrEqualTo(ZTScaleValue(110))
        }
        
        sizeLabel.snp.makeConstraints {
            $0.bottom.equalTo(timeLabel)
            $0.left.equalTo(timeLabel.snp.right).offset(ZTScaleValue(40))
            $0.width.lessThanOrEqualTo(ZTScaleValue(110))
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(iconImgView.snp.bottom).offset(ZTScaleValue(15.5))
            $0.left.equalTo(iconImgView)
            $0.right.equalToSuperview().offset(-ZTScaleValue(18.5))
            $0.height.equalTo(ZTScaleValue(0.5))
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
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

}
