//
//  FileDetailAlertView.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/19.
//

import UIKit
import  AVFoundation
import  MobileCoreServices

class FileDetailAlertView: UIView {
    enum FileDetailButtonType {
        case open
        case download
        case move
        case copy
        case rename
        case delete
        case preview
        
        var icon: UIImage? {
            switch self {
            case .open:
                return UIImage.assets(.otherApp_open)
            case .download:
                return UIImage.assets(.download_black)
            case .move:
                return UIImage.assets(.move_black)
            case .copy:
                return UIImage.assets(.copy_black)
            case .rename:
                return UIImage.assets(.resetName_black)
            case .delete:
                return UIImage.assets(.delete_black)
            case .preview:
                return UIImage.assets(.preview_black)
            }
        }
        
        var description: String {
            switch self {
            case .open:
                return "其他应用打开".localizedString
            case .download:
                return "下载".localizedString
            case .move:
                return "移动到".localizedString
            case .copy:
                return "复制到".localizedString
            case .rename:
                return "重命名".localizedString
            case .delete:
                return "删除".localizedString
            case .preview:
                return "查看".localizedString
            }
        }
    }
    
    var currentModel = FileModel()
    

    var selectCallback: ((_ type: FileDetailButtonType) -> ())?

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
    
    private var buttonData = [FileDetailButtonType]()
    
    //fileInfo
    lazy var iconImgView = ImageView().then{
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.myFile_tab)
        $0.clipsToBounds = true
    }
    
    lazy var fileNameLabel = UILabel().then{
        $0.backgroundColor = .clear
        $0.lineBreakMode = .byTruncatingMiddle
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

    //funtionCollectionView
    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        $0.itemSize = CGSize(width: ZTScaleValue(100), height:  ZTScaleValue(120))
        //行列间距
        $0.minimumLineSpacing = ZTScaleValue(14.5)
        $0.minimumInteritemSpacing = ZTScaleValue(10)
        //设置内边距
        $0.sectionInset = UIEdgeInsets(top: ZTScaleValue(15), left: ZTScaleValue(17.5), bottom: ZTScaleValue(15), right: ZTScaleValue(17.5))
    }

    lazy var funtionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then{
        $0.backgroundColor = .clear
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.alwaysBounceHorizontal = false
        $0.isScrollEnabled = false
        $0.register(FileDetailFuntionCell.self, forCellWithReuseIdentifier: FileDetailFuntionCell.reusableIdentifier)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, callback: ((_ type: FileDetailButtonType) -> ())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
        self.titleLabel.text = title
        self.selectCallback = callback

        funtionCollectionView.reloadData()
    }    

    public func setCurrentFileModel(file: FileModel, types: [FileDetailButtonType], filePath: String = ""){
        currentModel = file
        if file.type == 0 {
            iconImgView.image = .assets(.folder_icon)
        } else {
            iconImgView.setImage(urlString: AreaManager.shared.currentArea.requestURL.absoluteString + "/wangpan/api/" + currentModel.thumbnail_url, placeHolder: ZTCTool.fileImageBy(fileName: currentModel.name))
            
        }
        
        fileNameLabel.text = file.name
        timeLabel.text = TimeTool.timeIntervalChangeToTimeStr(timeInterval: Double(file.mod_time), "yyyy-MM-dd")
        sizeLabel.text = ZTCTool.convertFileSize(size: file.size)
        
//        let types: [FileDetailButtonType] = [.open, .download, .move, .copy, .rename, .delete]
        var buttons = types
        
        if currentModel.write == 0 {//无可写权限
            buttons = types.filter({$0 != .download && $0 != .rename})
        }
        
        var newButtons = buttons
        if currentModel.deleted == 0 {//无删除权限
            newButtons = buttons.filter({$0 != .move && $0 != .delete})
        }
        buttonData = newButtons
        
        funtionCollectionView.reloadData()
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
        
        containerView.addSubview(funtionCollectionView)
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
            $0.right.equalTo(-ZTScaleValue(15))
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

        funtionCollectionView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
    
    private func dismissWithCallback(idx: Int) {
        self.endEditing(true)
        self.selectCallback?(buttonData[idx])
//        super.removeFromSuperview()
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
    
}

extension FileDetailAlertView: UICollectionViewDelegate, UICollectionViewDataSource {
    //cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonData.count
    }
    //cell 具体内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileDetailFuntionCell.reusableIdentifier, for: indexPath) as! FileDetailFuntionCell
        cell.funtionImgView.image = buttonData[indexPath.item].icon
        cell.funtionTitleLabel.text = buttonData[indexPath.item].description
//        if currentModel.write == 0 {//无可写权限
//            if indexPath.item == 0 || indexPath.item == 3{
//                cell.funtionImgView.alpha = 0.5
//                cell.funtionTitleLabel.alpha = 0.5
//                cell.isUserInteractionEnabled = false
//            }
//
//        }else{
//            if indexPath.item == 0 || indexPath.item == 3{
//                cell.funtionImgView.alpha = 1
//                cell.funtionTitleLabel.alpha = 1
//                cell.isUserInteractionEnabled = true
//                }
//            }
//
//
//        if currentModel.deleted == 0 {//无删除权限
//            if indexPath.item == 1 || indexPath.item == 4 {
//                cell.funtionImgView.alpha = 0.5
//                cell.funtionTitleLabel.alpha = 0.5
//                cell.isUserInteractionEnabled = false
//            }
//        }else{
//            if indexPath.item == 1 || indexPath.item == 4 {
//                cell.funtionImgView.alpha = 1
//                cell.funtionTitleLabel.alpha = 1
//                cell.isUserInteractionEnabled = true
//            }
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissWithCallback(idx: indexPath.item)
    }
}



class ButtonModel: NSObject {
    var img: UIImage?
    var name = ""
    
}
