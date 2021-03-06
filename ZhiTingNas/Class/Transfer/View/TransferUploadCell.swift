//
//  TransferUploadCell.swift
//  ZhiTingNas
//
//  Created by imac on 2021/6/1.
//

import UIKit
import  AVFoundation
import  MobileCoreServices

class TransferUploadCell: UITableViewCell,ReusableView {
    var stateBtnCallback: (() -> ())?
    
    lazy var iconImgView = ImageView().then{
        $0.image = .assets(.myFile_tab)
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    lazy var fileNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    //上传进度
    lazy var fileProgressLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }
    
    //上传速率或状态
    lazy var fileStateLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }

    //状态按钮
    lazy var stateBtn = Button().then{
        $0.isEnhanceClick = true
        $0.setImage(.assets(.fileSelected_normal), for: .normal)
        $0.setImage(.assets(.fileSelected_selected), for: .selected)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }
    
    lazy var progressView = UIProgressView().then{
        $0.progressTintColor = .custom(.blue_2da3f6)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUploadModel(model: GoFileUploadInfoModel, filePath: String = "") {
        fileNameLabel.text = model.name
        progressView.setProgress(model.percentage, animated: false)
        fileStateLabel.text = "\(model.status)"
//        if filePath == "" {
        if model.thumbnail_url != "" {
            iconImgView.setImage(urlString: AreaManager.shared.currentArea.requestURL.absoluteString + "/wangpan/api/" + model.thumbnail_url, placeHolder: ZTCTool.fileImageBy(fileName: model.name))
        }else{
            iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
        }
//        }else{
//            let fileTypeStrs = model.name.components(separatedBy: ".")
//            switch fileTypeStrs.last?.lowercased() {
//                case "mp4", "m4v", "avi", "mkv", "mov", "mpg", "mpeg", "vob", "ram", "rm", "rmvb", "asf", "wmv", "webm", "m2ts", "movie" :
//                    self.getThumbnail(url: filePath)
//
//                case "psd", "pdd", "psdt", "psb", "bmp", "rle", "dib", "gif", "dcm", "dc3", "dic", "eps", "iff", "tdi", "jpg", "jpeg", "jpf", "jpx", "jp2", "j2c", "j2k", "jpc", "jps", "pcx", "pdp", "raw", "pxr", "png", "pbm", "pgm", "ppm", "pnm", "pfm", "pam", "sct", "tga", "vda", "icb", "vst", "tif", "tiff", "mpo", "heic" :
//
//                let data = try! Data(contentsOf: URL(string: filePath)!)
//                iconImgView.image = UIImage(data: data)//UIImage(contentsOfFile: filePath)
//
//                default:
//                iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
//            }
//
//        }
        stateBtn.transform = .identity
        stateBtn.isHidden = false
        switch model.status {
        case 0:
            progressView.isHidden = false
            fileStateLabel.text = "等待上传"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(.assets(.btn_download), for: .normal)
            stateBtn.transform = .init(rotationAngle: .pi)
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.upload))/\(ZTCTool.convertFileSize(size: model.size))"
            }
        case 1:
            progressView.isHidden = false
            fileStateLabel.text = "\(ZTCTool.convertFileSize(size:model.speeds))/s"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(.assets(.btn_stop), for: .normal)
            fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.upload))/\(ZTCTool.convertFileSize(size: model.size))"
        case 2:
            progressView.isHidden = false
            fileStateLabel.text = "等待上传"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(.assets(.btn_download), for: .normal)
            stateBtn.transform = .init(rotationAngle: .pi)
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.upload))/\(ZTCTool.convertFileSize(size: model.size))"
            }
        case 3:
            fileStateLabel.text = "\(ZTCTool.convertFileSize(size: model.size))"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(nil, for: .normal)
            progressView.isHidden = true
            fileProgressLabel.text = TimeTool.timeIntervalChangeToTimeStr(timeInterval: Double(model.create_time))
            
            fileNameLabel.snp.remakeConstraints {
                $0.bottom.equalTo(progressView.snp.top).offset(-ZTScaleValue(5))
                $0.left.equalTo(progressView)
                $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            }
            
            fileProgressLabel.snp.remakeConstraints {
                $0.top.equalTo(progressView.snp.top)
                $0.left.equalTo(progressView)
                $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
            }
            
            fileStateLabel.snp.remakeConstraints {
                $0.top.equalTo(progressView.snp.top)
                $0.left.equalTo(fileProgressLabel.snp.right).offset(ZTScaleValue(50))
                $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
            }
        case 4:
            progressView.isHidden = false
            fileStateLabel.text = "上传失败"
            fileStateLabel.textColor = .custom(.red_fe0000)
            stateBtn.setImage(.assets(.btn_reDownload), for: .normal)
            fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.upload))/\(ZTCTool.convertFileSize(size: model.size))"
            
        case 5:
            progressView.isHidden = false
            fileStateLabel.text = "生成临时文件中"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.isHidden = true
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.upload))/\(ZTCTool.convertFileSize(size: model.size))"
            }
        default:
            break
        }

        setupConstraints()
        
    }

    private func getThumbnail(url:String){
        //异步获取网络视频
        DispatchQueue.global().async {
            //获取网络视频
            let  videoURL =  URL(string: url)!
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
    
    private func setupViews(){
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(fileProgressLabel)
        contentView.addSubview(fileStateLabel)
        contentView.addSubview(stateBtn)
    }
    
    private func setupConstraints(){
        iconImgView.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(30))
        }
        progressView.snp.remakeConstraints {
            $0.centerY.equalTo(iconImgView).offset(ZTScaleValue(5))
            $0.left.equalTo(iconImgView.snp.right).offset(ZTScaleValue(15))
            $0.width.equalTo(ZTScaleValue(250))
            $0.height.equalTo(ZTScaleValue(2))
        }
        
        fileNameLabel.snp.remakeConstraints {
            $0.bottom.equalTo(progressView.snp.top).offset(-ZTScaleValue(5))
            $0.left.equalTo(progressView)
            $0.right.equalTo(stateBtn.snp.left).offset(ZTScaleValue(-10))
        }

        fileProgressLabel.snp.remakeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalTo(progressView)
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
        }
        
        fileStateLabel.snp.remakeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(ZTScaleValue(5))
            $0.right.equalTo(progressView)
            $0.width.greaterThanOrEqualTo(ZTScaleValue(50))
        }
        
        stateBtn.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(20))
        }
    }
    
    
    @objc private func buttonOnPress(sender:Button){
        stateBtnCallback?()
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
