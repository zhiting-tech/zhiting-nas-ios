//
//  FolderTableViewCell.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/6/17.
//

import UIKit
import AVKit

enum FolderTableViewCellType {
    case normal
    case download
}

class FolderTableViewCell: UITableViewCell,ReusableView {

    
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.myFile_tab)
        $0.layer.cornerRadius = 4.ztScaleValue
        $0.clipsToBounds = true
    }
    
    //加密文件夹
    lazy var encryptImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
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
    
    lazy var arrowBtn = Button().then{
        $0.setImage(.assets(.download_arrow), for: .normal)
    }

    
    var currentFileModel = FileModel()
    var currentShareFileModel = FileModel()
    var cellType = FolderTableViewCellType.normal
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setModel(currentModel: FileModel, filePath: String = "", type: FolderTableViewCellType = .normal) {
        currentFileModel = currentModel
        cellType = type
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
            if currentModel.thumbnail_url == ""{
                if filePath != "" {
                    switch ZTCTool.resourceTypeBy(fileName: currentModel.name) {
                    case .video:
                        iconImgView.image = ZTCTool.fileImageBy(fileName: currentModel.name)
                        self.getThumbnail(url: filePath)
                        break
                    case .picture:
                        iconImgView.setImage(urlString: filePath, placeHolder: ZTCTool.fileImageBy(fileName: currentModel.name))
                    default:
                        iconImgView.image = ZTCTool.fileImageBy(fileName: currentModel.name)
                    }
                }else{
                    iconImgView.image = ZTCTool.fileImageBy(fileName: currentModel.name)
                }
            }else{
                iconImgView.setImage(urlString: AreaManager.shared.currentArea.requestURL.absoluteString + "/wangpan/api/" + currentModel.thumbnail_url, placeHolder: ZTCTool.fileImageBy(fileName: currentModel.name))
            }
            
            fileSizeLabel.isHidden = false
        }

        fileNameLabel.text = currentModel.name
        fileTimeLabel.text = TimeTool.timeIntervalChangeToTimeStr(timeInterval: Double(currentModel.mod_time))//String(format: "%d", currentModel.mod_time)
        fileSizeLabel.text = ZTCTool.convertFileSize(size: currentModel.size)
        selectBtn.isSelected = currentModel.isSelected
        setupViews()
    }
        
    private func setupViews(){
//        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(encryptImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(selectBtn)
        contentView.addSubview(arrowBtn)
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
        
        arrowBtn.snp.makeConstraints {
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
        
        fileSizeLabel.snp.makeConstraints {
            $0.bottom.equalTo(fileTimeLabel)
            $0.left.equalTo(fileTimeLabel.snp.right).offset(ZTScaleValue(50))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }

        fileTimeLabel.snp.makeConstraints{
            $0.bottom.equalTo(iconImgView)
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.lessThanOrEqualTo(ZTScaleValue(200))
        }
        
        switch cellType {
        case .normal:
            selectBtn.isHidden = false
            arrowBtn.isHidden = true
        case .download:
            selectBtn.isHidden = true
            arrowBtn.isHidden = false
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
    
    private func getThumbnail(url:String){
//        异步获取网络视频
        DispatchQueue.global().async {
            //获取网络视频
            guard let videoURL =  URL(string: url) else{
                return
            }
            let  avAsset =  AVURLAsset(url: videoURL)

            //生成视频截图
            let  generator =  AVAssetImageGenerator (asset: avAsset)
            generator.appliesPreferredTrackTransform =  true
            let  time =  CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
            var  actualTime: CMTime  =  CMTimeMake(value: 0, timescale: 0)
            if let imageRef: CGImage = try? generator.copyCGImage(at: time, actualTime: &actualTime) {
                let frameImg = UIImage(cgImage: imageRef)
                //在主线程中显示截图
                DispatchQueue.main.async {
                    self.iconImgView.image = frameImg
                }
            }

        }
    }

}

