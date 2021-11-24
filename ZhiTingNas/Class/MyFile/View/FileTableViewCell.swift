//
//  FileTableViewCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/18.
//

import UIKit

class FileTableViewCell: UITableViewCell,ReusableView {
    
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.myFile_tab)
    }
    
    //加密文件夹
    lazy var encryptImgView = ImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.image = .assets(.encrypt_icon)
    }
    
    lazy var fileNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    
    lazy var fileSourceLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }

    
    lazy var selectBtn = Button().then{
        $0.setImage(.assets(.fileSelected_normal), for: .normal)
        $0.setImage(.assets(.fileSelected_selected), for: .selected)

    }
    
    var currentFileModel = FileModel()
    var currentShareFileModel = FileModel()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setModel(currentModel: FileModel) {
        currentFileModel = currentModel
        encryptImgView.isHidden = true
        if currentModel.type == 0 {
            iconImgView.image = .assets(.folder_icon)
            if currentModel.is_encrypt == 0 {
                encryptImgView.isHidden = true
            }else{
                encryptImgView.isHidden = false
            }
        }else{
            iconImgView.image = ZTCTool.fileImageBy(fileName: currentModel.name)
        }

        fileNameLabel.text = currentModel.name
        fileSourceLabel.text = String(format: "%d", currentModel.mod_time)
        selectBtn.isSelected = currentModel.isSelected
        setupViews(isShare: false)
    }
    
    public func setShareModel(currentModel: FileModel){
        currentShareFileModel = currentModel
        encryptImgView.isHidden = true
        if currentModel.is_family_path == 1 {//家庭文件is_family_path
            iconImgView.image = .assets(.folder_icon)
        }else{
            if currentModel.from_user == "" {
                iconImgView.image = .assets(.folder_icon)
            } else {
                iconImgView.image = .assets(.share_folder_icon)
            }
            
        }

        fileNameLabel.text = currentModel.name
        fileSourceLabel.text = "\(currentModel.from_user) 共享给我"
        selectBtn.isSelected = currentModel.isSelected
        setupViews(isShare: true)

    }
    
    private func setupViews(isShare: Bool){
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(encryptImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(selectBtn)
        
        iconImgView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(35))
            $0.left.equalTo(ZTScaleValue(15))
        }
        
        encryptImgView.snp.makeConstraints {
            $0.width.height.equalTo(ZTScaleValue(12))
            $0.right.equalTo(iconImgView).offset(ZTScaleValue(6))
            $0.bottom.equalTo(iconImgView).offset(ZTScaleValue(3))
        }
        
        selectBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(20))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalToSuperview()
        }
        
        if isShare && currentShareFileModel.from_user != "" {
                fileSourceLabel.isHidden = false
                contentView.addSubview(fileSourceLabel)
                fileNameLabel.snp.makeConstraints{
                    $0.top.equalTo(iconImgView)
                    $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
                    $0.width.lessThanOrEqualTo(ZTScaleValue(200))
                }
                
                fileSourceLabel.snp.makeConstraints{
                    $0.bottom.equalTo(iconImgView)
                    $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
                    $0.width.lessThanOrEqualTo(ZTScaleValue(200))
                }
        }else{
            fileNameLabel.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
                $0.width.lessThanOrEqualTo(ZTScaleValue(200))
            }
            fileSourceLabel.isHidden = true
        }

    }
    
    override func prepareForReuse() {
        iconImgView.removeFromSuperview()
        encryptImgView.removeFromSuperview()
        fileNameLabel.removeFromSuperview()
        fileSourceLabel.removeFromSuperview()
        selectBtn.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
