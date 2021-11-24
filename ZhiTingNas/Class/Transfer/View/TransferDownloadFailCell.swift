//
//  TransferDownloadFailCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/10/18.
//


import UIKit

class TransferDownloadFailCell: UITableViewCell,ReusableView {
    var btnCallback: (() -> ())?
    
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.myFile_tab)
    }
    
    lazy var fileNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }

    
    //下载状态
    lazy var fileStateLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.red_fe0000)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
        $0.text = "下载失败".localizedString
    }
    
    lazy var fileSizeLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }

    //状态按钮
    lazy var ignoreBtn = Button().then {
        $0.isEnhanceClick = true
        $0.backgroundColor = .custom(.blue_427aed).withAlphaComponent(0.1)
        $0.setTitleColor(.custom(.blue_427aed), for: .normal)
        $0.setTitle("忽略", for: .normal)
        $0.titleLabel?.font = .font(size: 12.ztScaleValue, type: .medium)
        $0.layer.cornerRadius = 10.ztScaleValue
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setDownloadModel(model: GoFileDownloadInfoModel) {
        fileNameLabel.text = model.name
        fileSizeLabel.text = ZTCTool.convertFileSize(size: model.size)
        iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
        
        
    }

    
    private func setupViews(){
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileStateLabel)
        contentView.addSubview(fileSizeLabel)
        contentView.addSubview(ignoreBtn)
    }
    
    private func setupConstraints(){
        iconImgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15.ztScaleValue)
            $0.left.equalTo(14.ztScaleValue)
            $0.width.height.equalTo(26.ztScaleValue)
            $0.bottom.equalToSuperview().offset(-15.ztScaleValue)
        }

        
        fileNameLabel.snp.makeConstraints {
            $0.top.equalTo(iconImgView.snp.top).offset(-3.5.ztScaleValue)
            $0.left.equalTo(iconImgView.snp.right).offset(14.ztScaleValue)
            $0.right.equalTo(ignoreBtn.snp.left).offset(-15.ztScaleValue)
        }
        
        fileStateLabel.snp.makeConstraints {
            $0.top.equalTo(fileNameLabel.snp.bottom)
            $0.left.equalTo(iconImgView.snp.right).offset(14.ztScaleValue)
        }
        
        fileSizeLabel.snp.makeConstraints {
            $0.top.equalTo(fileNameLabel.snp.bottom)
            $0.left.equalTo(fileStateLabel.snp.right).offset(30.ztScaleValue)
        }
        
        ignoreBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-15.ztScaleValue)
            $0.height.equalTo(20.ztScaleValue)
            $0.width.equalTo(40.ztScaleValue)
        }
    }

    
    @objc private func buttonOnPress(sender:Button){
        btnCallback?()
    }

}
