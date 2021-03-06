//
//  TransferDownloadCell.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/1.
//

import UIKit
import AVKit

class TransferDownloadCell: UITableViewCell,ReusableView {
    var stateBtnCallback: (() -> ())?
    
    var dirFailInfoCallback: (() -> ())?
    
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 4
        $0.image = .assets(.myFile_tab)
        $0.clipsToBounds = true
    }
    
    lazy var fileNameLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
    }
    //下载进度
    lazy var fileProgressLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }
    
    //下载速率或状态
    lazy var fileStateLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.textColor = .custom(.gray_a2a7ae)
        $0.font = .font(size: ZTScaleValue(10), type: .medium)
    }

    //状态按钮
    lazy var stateBtn = Button().then {
        $0.isEnhanceClick = true
        $0.setImage(.assets(.fileSelected_normal), for: .normal)
        $0.setImage(.assets(.fileSelected_selected), for: .selected)
        $0.addTarget(self, action: #selector(buttonOnPress(sender:)), for: .touchUpInside)
    }
    
    //状态按钮
    lazy var errInfoBtn = Button().then {
        $0.isHidden = true
        $0.isEnhanceClick = true
        $0.setImage(.assets(.error_info), for: .normal)
        $0.addTarget(self, action: #selector(dirFailInfo), for: .touchUpInside)
    }
    
    lazy var progressView = UIProgressView().then {
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
    
    
    /// 设置下载model
    /// - Parameters:
    ///   - model: gomobile 下载model
    ///   - filePath: 本地文件地址
    func setDownloadModel(model: GoFileDownloadInfoModel, filePath: String = "") {
        fileNameLabel.text = model.name
        progressView.setProgress(model.percentage, animated: false)
        fileStateLabel.text = "\(model.status)"
        if model.type == "dir" {
            iconImgView.contentMode = .scaleAspectFit
            iconImgView.image = .assets(.folder_icon)
        } else {
            
            if model.thumbnail_url == "" {
                if filePath != "" {
                    switch ZTCTool.resourceTypeBy(fileName: model.name) {
                    case .video:
                        iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
                        self.getThumbnail(url: filePath)
                    case .picture:
                        iconImgView.setImage(urlString: filePath, placeHolder: ZTCTool.fileImageBy(fileName: model.name))
                    default:
                        iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
                    }
                } else {
                    iconImgView.image = ZTCTool.fileImageBy(fileName: model.name)
                }
            } else {
                iconImgView.setImage(urlString: AreaManager.shared.currentArea.requestURL.absoluteString + "/wangpan/api" + model.thumbnail_url, placeHolder: ZTCTool.fileImageBy(fileName: model.name))

            }
            
        }
        
        switch model.status {
        case 0:
            progressView.isHidden = false
            fileStateLabel.text = "等待下载"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(.assets(.btn_download), for: .normal)
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.downloaded))/\(ZTCTool.convertFileSize(size: model.size))"
            }
            
        case 1:
            progressView.isHidden = false
            fileStateLabel.text = "\(ZTCTool.convertFileSize(size:model.speeds))/s"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            stateBtn.setImage(.assets(.btn_stop), for: .normal)
            fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.downloaded))/\(ZTCTool.convertFileSize(size: model.size))"
        case 2:
            fileStateLabel.text = "等待下载"
            fileStateLabel.textColor = .custom(.gray_a2a7ae)
            progressView.isHidden = false
            stateBtn.setImage(.assets(.btn_download), for: .normal)
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.downloaded))/\(ZTCTool.convertFileSize(size: model.size))"
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
            fileStateLabel.text = "下载失败"
            fileStateLabel.textColor = .custom(.red_fe0000)
            stateBtn.setImage(.assets(.btn_reDownload), for: .normal)
            if model.size == 0 {
                fileProgressLabel.text = "--/--"
            } else {
                fileProgressLabel.text = "\(ZTCTool.convertFileSize(size: model.downloaded))/\(ZTCTool.convertFileSize(size: model.size))"
            }
            
            if model.type == "dir" {
                errInfoBtn.isHidden = false
                fileStateLabel.isUserInteractionEnabled = true
                fileStateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dirFailInfo)))
            } else {
                fileStateLabel.isUserInteractionEnabled = false
                errInfoBtn.isHidden = true
            }

        default:
            break
        }
        setupConstraints()
        
    }

    
    private func setupViews(){
        selectionStyle = .none
        errInfoBtn.isHidden = true
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(iconImgView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(fileProgressLabel)
        contentView.addSubview(fileStateLabel)
        contentView.addSubview(errInfoBtn)
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
            
        }
        
        errInfoBtn.snp.remakeConstraints {
            $0.centerY.equalTo(fileStateLabel.snp.centerY)
            $0.left.equalTo(fileStateLabel.snp.right).offset(10)
            $0.height.width.equalTo(10.ztScaleValue)
        }
        
        stateBtn.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-ZTScaleValue(15))
            $0.width.height.equalTo(ZTScaleValue(20))
        }
    }
    
    private func getThumbnail(url:String){

        //异步获取网络视频
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

    
//    override func prepareForReuse() {
//        iconImgView.removeFromSuperview()
//        fileNameLabel.removeFromSuperview()
//        progressView.removeFromSuperview()
//        fileProgressLabel.removeFromSuperview()
//        fileStateLabel.removeFromSuperview()
//        stateBtn.removeFromSuperview()
//        errInfoBtn.removeFromSuperview()
//    }
    
    @objc private func dirFailInfo() {
        dirFailInfoCallback?()
    }

    @objc private func buttonOnPress(sender: Button){
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
