//
//  FolderTableViewCell.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/6/17.
//

import UIKit

class FolderTableViewCell: UITableViewCell,ReusableView {

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
    
    lazy var fileTimeLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }

    lazy var fileSizeLabel = UILabel().then{
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
            fileSizeLabel.isHidden = true
            if currentModel.is_encrypt == 0 {
                encryptImgView.isHidden = true
            }else{
                encryptImgView.isHidden = false
            }
        }else{
            iconImgView.image = ZTCTool.fileImageBy(fileName: currentModel.name)
            fileSizeLabel.isHidden = false
        }

        fileNameLabel.text = currentModel.name
        fileTimeLabel.text = TimeTool.timeIntervalChangeToTimeStr(timeInterval: Double(currentModel.mod_time))//String(format: "%d", currentModel.mod_time)
        fileSizeLabel.text = ZTCTool.convertFileSize(size: currentModel.size)
        selectBtn.isSelected = currentModel.isSelected
        setupViews()
    }
        
    private func setupViews(){
        contentView.addSubview(iconImgView)
        contentView.addSubview(encryptImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(selectBtn)
        contentView.addSubview(fileTimeLabel)
        contentView.addSubview(fileSizeLabel)

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
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(30))
            $0.height.equalToSuperview()
        }
        
        fileNameLabel.snp.makeConstraints{
            $0.top.equalTo(iconImgView)
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
            
        fileTimeLabel.snp.makeConstraints{
            $0.bottom.equalTo(iconImgView)
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
        fileSizeLabel.snp.makeConstraints {
            $0.bottom.equalTo(fileTimeLabel)
            $0.left.equalTo(fileTimeLabel.snp.right).offset(ZTScaleValue(50))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
    }
    
    override func prepareForReuse() {
        iconImgView.removeFromSuperview()
        fileNameLabel.removeFromSuperview()
        fileTimeLabel.removeFromSuperview()
        fileSizeLabel.removeFromSuperview()
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

